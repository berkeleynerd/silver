with SPARK.Big_Integers;
with Silver_Report_Observations;
with Silver_Report_Projection_Observations;
with Silver_Report_Observation_Windows;

package body Silver_Library_Reports with SPARK_Mode => On is
   use SPARK.Big_Integers;
   use type Procedure_Bindings.Parameter_Mode;
   package Observations renames Silver_Report_Observations;
   use type Observations.Nesting;
   use type Observations.Member;
   type Audit_Kind is
     (IO_Body, Libc_Interface, Argument_Body, Argv_Interface,
      Static_Main, Static_Put, Static_Mixed,
      Main_Body, Main_Put, Main_Mixed, Argument_Effects, Binding_Main, Argument_Binding_Main,
      Argument_Without_Query, Argument_Put_Without_Query, Argument_Mixed_Without_Query,
      Argument_Effects_Without_Query,
      Assignment_Main, Assignment_Effects, Assignment_Put, Assignment_Mixed,
      Selected_Main, Selected_Put, Selected_Mixed, Selected_Effects,
      Selected_Without_Query, Selected_Put_Without_Query, Selected_Mixed_Without_Query,
      Selected_Effects_Without_Query, Selected_Binding_Main);
   subtype Application_Audit is Audit_Kind range Static_Main .. Selected_Binding_Main;
   subtype Mutable_Audit is Audit_Kind range Assignment_Main .. Selected_Binding_Main;
   function Audit_Of (Kind : Report_Kind) return Audit_Kind is
     (case Kind is
        when Library_Body => IO_Body,
        when Imported_Interface => Libc_Interface,
        when Arguments_Body => Argument_Body,
        when Runtime_Interface => Argv_Interface);

   Atom_Empty : constant String := "";
   Initialization_Prefix : constant String := """initialization of \""";
   Initialization_Suffix : constant String := "\"" has no effect""";
   Atom_imprecise_image : constant String := "imprecise-image";
   Atom_image_message : constant String := "references to the \""Image\"" attribute are handled in an imprecise way, so nothing will be known about the evaluation of the attribute reference apart from a bound on its length [imprecise-image]";
   Atom_image_message_lower : constant String := "references to the \""image\"" attribute are handled in an imprecise way, so nothing will be known about the evaluation of the attribute reference apart from a bound on its length [imprecise-image]";
   Atom_image_message_upper : constant String := "references to the \""IMAGE\"" attribute are handled in an imprecise way, so nothing will be known about the evaluation of the attribute reference apart from a bound on its length [imprecise-image]";
   Atom_array_initialization : constant String := "array-initialization";
   Atom_array_initialization_message : constant String := "initialization of an array in FOR loop is handled imprecisely [array-initialization]";
   Atom_unknown : constant String := "unknown";
   Unused_Formal_Prefix : constant String := """unused variable \""";
   Unused_Formal_Suffix : constant String := "\""""";
   Atom_UNUSED_VARIABLE : constant String := "UNUSED_VARIABLE";
   Atom_INEFFECTIVE : constant String := "INEFFECTIVE";
   Atom_DEAD_CODE : constant String := "DEAD_CODE";
   Atom_statement_no_effect : constant String := "statement has no effect";
   Atom_statement_unreachable : constant String := "this statement is never reached";
   Atom_warning : constant String := "warning";
   Atom_unused_assignment : constant String := "unused assignment";
   Atom_unused_Written_Count : constant String := "\""Written_Count\"" is set by \""Put_Line\"" but not used after the call";
   Atom_unused_Flushed : constant String := "\""Flushed\"" is set by \""Put_Line\"" but not used after the call";
   Atom_unused_Succeeded : constant String := "\""Succeeded\"" is set by \""Put_Line\"" but not used after the call";
   Atom_unused_Written_Bytes : constant String := "\""Written_Bytes\"" is set by \""Put_Line\"" but not used after the call";
   Atom_put_unused_Written_Count : constant String := "\""Written_Count\"" is set by \""Put\"" but not used after the call";
   Atom_put_unused_Flushed : constant String := "\""Flushed\"" is set by \""Put\"" but not used after the call";
   Atom_put_unused_Succeeded : constant String := "\""Succeeded\"" is set by \""Put\"" but not used after the call";
   Atom_put_unused_Written_Bytes : constant String := "\""Written_Bytes\"" is set by \""Put\"" but not used after the call";
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
   Atom_Silver_IO_Put : constant String := "Silver_IO.Put";
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
   Atom_VC_LENGTH_CHECK : constant String := "VC_LENGTH_CHECK";
   Atom_VC_OVERFLOW_CHECK : constant String := "VC_OVERFLOW_CHECK";
   Atom_VC_DIVISION_CHECK : constant String := "VC_DIVISION_CHECK";
   Atom_VC_INDEX_CHECK : constant String := "VC_INDEX_CHECK";
   Atom_all : constant String := "all";
   Atom_info : constant String := "info";
   Atom_UNINITIALIZED : constant String := "UNINITIALIZED";
   Atom_SUBPROGRAM_TERMINATION : constant String := "SUBPROGRAM_TERMINATION";
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
   JSON_check_tree : constant String := "check_tree";
   JSON_unproved_status : constant String := "unproved_status";
   JSON_status : constant String := "status";
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

   --  Bounded / unbounded observation correspondence. The uncapped equations
   --  are independently byte-derived; these lemmas identify their results on
   --  each finite String with the exact scanner used by the auditor.
   function Observation_Nesting (Stack : Nesting) return Observations.Nesting is
     (Observations.Nesting (Stack)) with Ghost => Static;

   procedure Observation_Push (Stack : Nesting; Level : Positive; C : Character)
     with Ghost => Static, Global => null, Pre => Level <= 64,
       Post => Observation_Nesting (Pushed (Stack, Level, C)) =
         Observations.Pushed (Observation_Nesting (Stack), Level, C)
   is
      use type Observations.Nesting;
   begin
      pragma Assert (for all I in Stack'Range =>
        Observation_Nesting (Pushed (Stack, Level, C)) (I) =
          Observations.Pushed (Observation_Nesting (Stack), Level, C) (I));
   end Observation_Push;

   procedure Space_End_Observation (Text : String; Position : Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Position in 1 .. Text'Length + 1,
       Post => Observations.Space_End
         (Observations.From_String (Text), To_Big_Integer (Position)) =
           To_Big_Integer (Space_End (Text, Position)),
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position)
   is
   begin
      if Position <= Text'Length then
         pragma Assert (Observations.Bytes.Get
           (Observations.From_String (Text), To_Big_Integer (Position)) = Text (Position));
         if Space (Text (Position)) then
            Space_End_Observation (Text, Position + 1);
         end if;
      end if;
   end Space_End_Observation;

   procedure Value_From_Observation
     (Text : String; Start, Position : Offset; Openers : Nesting;
      Raw_Openers : Observations.Nesting;
      Level : Nesting_Level; Quoted, Escaped, Container : Boolean)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Start in 1 .. Text'Length + 1
         and then Position in Start .. Text'Length + 1
         and then Raw_Openers = Observation_Nesting (Openers),
       Post => Observations.Value_From
         (Observations.From_String (Text), To_Big_Integer (Start),
          To_Big_Integer (Position), Raw_Openers,
          Level, Quoted, Escaped, Container) =
         To_Big_Integer (Value_From
           (Text, Start, Position, Openers, Level, Quoted, Escaped, Container)),
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position)
   is
   begin
      if Position > Text'Length then
         return;
      end if;
      pragma Assert (Observations.Bytes.Get
        (Observations.From_String (Text), To_Big_Integer (Position)) = Text (Position));
      if Quoted then
         if Escaped then
            Value_From_Observation
              (Text, Start, Position + 1, Openers, Raw_Openers, Level, True, False, Container);
         elsif Text (Position) = '\' then
            Value_From_Observation
              (Text, Start, Position + 1, Openers, Raw_Openers, Level, True, True, Container);
         elsif Text (Position) = '"' then
            if Container then
               Value_From_Observation
                 (Text, Start, Position + 1, Openers, Raw_Openers, Level, False, False, Container);
            end if;
         else
            Value_From_Observation
              (Text, Start, Position + 1, Openers, Raw_Openers, Level, True, False, Container);
         end if;
      elsif Text (Position) = '"' then
         Value_From_Observation
           (Text, Start, Position + 1, Openers, Raw_Openers, Level, True, Escaped, Container);
      elsif Text (Position) in '{' | '[' then
         if Level < 64 then
            Observation_Push (Openers, Level + 1, Text (Position));
            Value_From_Observation
              (Text, Start, Position + 1, Pushed (Openers, Level + 1, Text (Position)),
               Observations.Pushed (Raw_Openers, Level + 1, Text (Position)), Level + 1, False, Escaped, Container);
         end if;
      elsif Text (Position) in '}' | ']' then
         if Level > 1
           and then not ((Text (Position) = '}' and then Openers (Level) /= '{')
             or else (Text (Position) = ']' and then Openers (Level) /= '['))
         then
            Value_From_Observation
              (Text, Start, Position + 1, Openers, Raw_Openers, Level - 1, False, Escaped, Container);
         end if;
      elsif not Container and then (Text (Position) = ',' or else Space (Text (Position))) then
         null;
      else
         Value_From_Observation
           (Text, Start, Position + 1, Openers, Raw_Openers, Level, False, Escaped, Container);
      end if;
   end Value_From_Observation;

   procedure Value_Spec_Observation (Text : String; Start : Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Start in 1 .. Text'Length + 1,
       Post => Observations.Value_Spec
         (Observations.From_String (Text), To_Big_Integer (Start)) =
           To_Big_Integer (Value_Spec (Text, Start))
   is
   begin
      if Start <= Text'Length then
         pragma Assert (Observations.Bytes.Get
           (Observations.From_String (Text), To_Big_Integer (Start)) = Text (Start));
      end if;
      Value_From_Observation
        (Text, Start, Start, Empty_Nesting, Observations.Empty_Nesting, 0, False, False,
         Start <= Text'Length and then Text (Start) in '{' | '[');
   end Value_Spec_Observation;

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

   --  The pinned producer follows the defining unit's casing when rendering
   --  this attribute name. Only these three complete messages are emitted.
   function Image_Message (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Image_Message (Text : String; Item : Span) return Boolean is
     (String_Equal (Text, Item, Atom_image_message)
      or else String_Equal (Text, Item, Atom_image_message_lower)
      or else String_Equal (Text, Item, Atom_image_message_upper));

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

   function Observation_Span (Item : Span) return Observations.Span is
     ((First => To_Big_Integer (Item.First), Last => To_Big_Integer (Item.Last)))
     with Ghost => Static;

   function Observation_Member (Item : Member) return Observations.Member is
     ((State => (case Item.State is
          when Broken => Observations.Broken,
          when Finished => Observations.Finished,
          when Present => Observations.Present),
       Key => Observation_Span (Item.Key), Value => Observation_Span (Item.Value),
       Next => To_Big_Integer (Item.Next))) with Ghost => Static;

   procedure Member_Observation (Text : String; Object : Span; Position : Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Object)
         and then Position in Object.First + 1 .. Text'Length + 1,
       Post => Observations.Member_Spec
         (Observations.From_String (Text), Observation_Span (Object),
          To_Big_Integer (Position)) = Observation_Member (Member_Spec (Text, Object, Position))
   is
      P : constant Offset := Space_End (Text, Position);
      K, C, V, L, T : Offset;
      Raw : constant Observations.Member := Observations.Member_Spec
        (Observations.From_String (Text), Observation_Span (Object), To_Big_Integer (Position));
      Bounded : constant Member := Member_Spec (Text, Object, Position);
   begin
      Space_End_Observation (Text, Position);
      if P < Object.Last then
         pragma Assert (Observations.Bytes.Get
           (Observations.From_String (Text), To_Big_Integer (P)) = Text (P));
      end if;
      if P >= Object.Last or else Text (P) /= '"' then
         pragma Assert (Raw = Observation_Member (Bounded));
         return;
      end if;
      Value_Spec_Observation (Text, P);
      K := Value_Spec (Text, P);
      if K = 0 or else K >= Object.Last then
         pragma Assert (Raw = Observation_Member (Bounded));
         return;
      end if;
      Space_End_Observation (Text, K + 1);
      C := Space_End (Text, K + 1);
      if C < Object.Last then
         pragma Assert (Observations.Bytes.Get
           (Observations.From_String (Text), To_Big_Integer (C)) = Text (C));
      end if;
      if C >= Object.Last or else Text (C) /= ':' then
         pragma Assert (Raw = Observation_Member (Bounded));
         return;
      end if;
      Space_End_Observation (Text, C + 1);
      V := Space_End (Text, C + 1);
      Value_Spec_Observation (Text, V);
      L := Value_Spec (Text, V);
      if L = 0 or else L >= Object.Last then
         pragma Assert (Raw = Observation_Member (Bounded));
         return;
      end if;
      Space_End_Observation (Text, L + 1);
      T := Space_End (Text, L + 1);
      if T < Object.Last then
         pragma Assert (Observations.Bytes.Get
           (Observations.From_String (Text), To_Big_Integer (T)) = Text (T));
      end if;
      if T >= Object.Last or else Text (T) /= ',' then
         pragma Assert (Raw = Observation_Member (Bounded));
         return;
      end if;
      Space_End_Observation (Text, T + 1);
      declare
         N : constant Offset := Space_End (Text, T + 1);
      begin
         if N >= Object.Last then
            pragma Assert (Bounded = Bad_Member);
            pragma Assert (Raw = Observations.Bad_Member);
         else
            pragma Assert (Bounded = (Present, (P, K), (V, L), N));
            pragma Assert (Raw = (Observations.Present,
              Observation_Span ((P, K)), Observation_Span ((V, L)), To_Big_Integer (N)));
         end if;
      end;
      pragma Assert (Raw = Observation_Member (Bounded));
   end Member_Observation;

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

   procedure Item_Observation (Text : String; Items : Span; Position : Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Post => Observations.Item_Spec
         (Observations.From_String (Text), Observation_Span (Items),
          To_Big_Integer (Position)) = Observation_Member (Item_Spec (Text, Items, Position))
   is
      P : constant Offset := Space_End (Text, Position);
      L, T : Offset;
   begin
      Space_End_Observation (Text, Position);
      if P >= Items.Last or else Text (P) /= '{' then return; end if;
      Value_Spec_Observation (Text, P);
      L := Value_Spec (Text, P);
      if L = 0 or else L >= Items.Last then return; end if;
      Space_End_Observation (Text, L + 1);
      T := Space_End (Text, L + 1);
      if T >= Items.Last or else Text (T) /= ',' then return; end if;
      Space_End_Observation (Text, T + 1);
   end Item_Observation;

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

   --  Projection congruence is stated over the scanner's actual byte-derived
   --  members, including their order and duplicate names. The relation permits
   --  a different value only for an immediate raw check_tree member. It does
   --  not equate objects merely because a selected policy already accepts them.
   Projection_Tree_Name : constant String := "check_tree";

   function Equal_Content
     (Left : String; L : Span; Right : String; R : Span) return Boolean is
     (Left'First = 1 and then Right'First = 1
      and then Valid (Left, L) and then Valid (Right, R)
      and then Left (L.First .. L.Last) = Right (R.First .. R.Last))
     with Ghost => Static;

   function Equivalent_Field
     (Left : String; L : Span; Right : String; R : Span) return Boolean is
     (if L = Missing then R = Missing
      elsif L = Malformed then R = Malformed
      else Equal_Content (Left, L, Right, R))
     with Ghost => Static;

   function Equivalent_Members
     (Left : String; L : Span; LP : Offset;
      Right : String; R : Span; RP : Offset; Erase_Tree : Boolean) return Boolean
     with Ghost => Static, Global => null,
       Pre => Left'First = 1 and then Left'Length <= Max_Report_Length
         and then Right'First = 1 and then Right'Length <= Max_Report_Length
         and then Valid (Left, L) and then Valid (Right, R)
         and then LP in L.First + 1 .. Left'Length + 1
         and then RP in R.First + 1 .. Right'Length + 1,
       Subprogram_Variant => (Decreases => (Left'Length + 1) - LP);

   function Equivalent_Members
     (Left : String; L : Span; LP : Offset;
      Right : String; R : Span; RP : Offset; Erase_Tree : Boolean) return Boolean is
     (declare LM : constant Member := Member_Spec (Left, L, LP);
              RM : constant Member := Member_Spec (Right, R, RP);
      begin
        LM.State = RM.State and then
          (case LM.State is
             when Broken | Finished => True,
             when Present =>
               Equal_Content (Left, LM.Key, Right, RM.Key)
               and then
                 ((Erase_Tree and then String_Equal (Left, LM.Key, Projection_Tree_Name))
                  or else Equal_Content (Left, LM.Value, Right, RM.Value))
               and then Equivalent_Members
                 (Left, L, LM.Next, Right, R, RM.Next, Erase_Tree)));

   procedure String_Content_Congruence
     (Left : String; L : Span; Right : String; R : Span; Expected : String)
     with Ghost => Static, Global => null,
       Pre => Left'First = 1 and then Left'Length <= Max_Report_Length
         and then Right'First = 1 and then Right'Length <= Max_Report_Length
         and then Equal_Content (Left, L, Right, R),
       Post => String_Equal (Left, L, Expected) = String_Equal (Right, R, Expected)
   is
   begin
      pragma Assert (L.Last - L.First = R.Last - R.First);
      pragma Assert (Left (L.First) = Right (R.First));
      pragma Assert (Left (L.Last) = Right (R.Last));
      if L.Last > L.First then
         pragma Assert
           (Left (L.First + 1 .. L.Last - 1) = Right (R.First + 1 .. R.Last - 1));
      end if;
   end String_Content_Congruence;

   procedure String_Name_Unique
     (Text : String; Key : Span; First, Second : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then String_Equal (Text, Key, First)
         and then String_Equal (Text, Key, Second),
       Post => First = Second
   is
   begin
      pragma Assert (First'Length = Second'Length);
      for I in 1 .. First'Length loop
         pragma Loop_Invariant
           (for all J in 1 .. I - 1 =>
              First (First'First + (J - 1)) = Second (Second'First + (J - 1)));
         pragma Assert (First (First'First + (I - 1)) = Text (Key.First + I));
         pragma Assert (Second (Second'First + (I - 1)) = Text (Key.First + I));
      end loop;
   end String_Name_Unique;

   procedure Merge_Field_Congruence
     (Left : String; L1, L2 : Span; Right : String; R1, R2 : Span)
     with Ghost => Static, Global => null,
       Pre => Equivalent_Field (Left, L1, Right, R1)
         and then Equivalent_Field (Left, L2, Right, R2),
       Post => Equivalent_Field
         (Left, Merge_Field (L1, L2), Right, Merge_Field (R1, R2))
   is
   begin
      null;
   end Merge_Field_Congruence;

   procedure Member_Field_Congruence
     (Left : String; L : Span; LP : Offset;
      Right : String; R : Span; RP : Offset; Erase_Tree : Boolean; Name : String)
     with Ghost => Static, Global => null,
       Pre => Left'First = 1 and then Left'Length <= Max_Report_Length
         and then Right'First = 1 and then Right'Length <= Max_Report_Length
         and then Valid (Left, L) and then Valid (Right, R)
         and then LP in L.First + 1 .. Left'Length + 1
         and then RP in R.First + 1 .. Right'Length + 1
         and then Equivalent_Members (Left, L, LP, Right, R, RP, Erase_Tree)
         and then (not Erase_Tree or else Name /= Projection_Tree_Name),
       Post => Equivalent_Field
         (Left, Field_From (Left, L, Name, LP), Right, Field_From (Right, R, Name, RP)),
       Subprogram_Variant => (Decreases => (Left'Length + 1) - LP)
   is
      LM : constant Member := Member_Spec (Left, L, LP);
      RM : constant Member := Member_Spec (Right, R, RP);
   begin
      if LM.State = Present then
         Member_Field_Congruence
           (Left, L, LM.Next, Right, R, RM.Next, Erase_Tree, Name);
         String_Content_Congruence (Left, LM.Key, Right, RM.Key, Name);
         if String_Equal (Left, LM.Key, Name) then
            if Erase_Tree and then String_Equal (Left, LM.Key, Projection_Tree_Name) then
               String_Name_Unique (Left, LM.Key, Name, Projection_Tree_Name);
            end if;
            pragma Assert (not Erase_Tree
              or else not String_Equal (Left, LM.Key, Projection_Tree_Name));
            pragma Assert (Equal_Content (Left, LM.Value, Right, RM.Value));
         end if;
         Merge_Field_Congruence
           (Left, (if String_Equal (Left, LM.Key, Name) then LM.Value else Missing),
            Field_From (Left, L, Name, LM.Next),
            Right, (if String_Equal (Right, RM.Key, Name) then RM.Value else Missing),
            Field_From (Right, R, Name, RM.Next));
      end if;
   end Member_Field_Congruence;

   procedure Object_Field_Congruence
     (Left : String; L : Span; Right : String; R : Span;
      Erase_Tree : Boolean; Name : String)
     with Ghost => Static, Global => null,
       Pre => Left'First = 1 and then Left'Length <= Max_Report_Length
         and then Right'First = 1 and then Right'Length <= Max_Report_Length
         and then Valid (Left, L) and then Valid (Right, R)
         and then Left (L.First) = '{' and then Left (L.Last) = '}'
         and then Right (R.First) = '{' and then Right (R.Last) = '}'
         and then Equivalent_Members
           (Left, L, L.First + 1, Right, R, R.First + 1, Erase_Tree)
         and then (not Erase_Tree or else Name /= Projection_Tree_Name),
       Post => Equivalent_Field
         (Left, Field_Spec (Left, L, Name), Right, Field_Spec (Right, R, Name))
   is
   begin
      Member_Field_Congruence
        (Left, L, L.First + 1, Right, R, R.First + 1, Erase_Tree, Name);
   end Object_Field_Congruence;

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

   function Empty_Object_Spec (Text : String; Item : Span) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Empty_Object_Spec (Text : String; Item : Span) return Boolean is
     (Valid (Text, Item) and then Text (Item.First) = '{'
      and then Text (Item.Last) = '}'
      and then Space_End (Text, Item.First + 1) = Item.Last);

   function Empty_Object (Text : String; Item : Span) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Empty_Object'Result = Empty_Object_Spec (Text, Item))
   is
      P : Offset;
   begin
      if not Valid (Text, Item) or else Text (Item.First) /= '{'
        or else Text (Item.Last) /= '}'
      then
         return False;
      end if;
      P := Item.First + 1;
      Skip_Space (Text, P);
      return P = Item.Last;
   end Empty_Object;

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

   --  Every local function has its own identity; coverage and uniqueness
   --  retain the distinction between used and unused declarations.
   subtype Entity_Kind is Natural range 0 .. 17 + Function_Bindings.Max_Functions + Procedure_Bindings.Max_Procedures;
   Unknown : constant Entity_Kind := 0;
   IO_Package : constant Entity_Kind := 1;
   Put_Line : constant Entity_Kind := 2;
   Put : constant Entity_Kind := 3;
   Libc_Package : constant Entity_Kind := 4;
   Put_Byte : constant Entity_Kind := 5;
   Flush : constant Entity_Kind := 6;
   Set_Exit_Status : constant Entity_Kind := 7;
   Arguments_Package : constant Entity_Kind := 8;
   Input_Is_Valid : constant Entity_Kind := 9;
   First_Or_Default : constant Entity_Kind := 10;
   Reject : constant Entity_Kind := 11;
   Is_Message : constant Entity_Kind := 12;
   Runtime_Package : constant Entity_Kind := 13;
   Argument_Count : constant Entity_Kind := 14;
   Argument : constant Entity_Kind := 15;
   Runtime_Exit_Status : constant Entity_Kind := 16;
   Main_Entity : constant Entity_Kind := 17;

   --  Keep the function IDs stable and put procedures in a disjoint block.
   Procedure_Entity_Base : constant Entity_Kind := Main_Entity + Function_Bindings.Max_Functions;

   function Is_Local_Function (Name : Entity_Kind; Functions : Function_Metadata) return Boolean is
     (Name in Main_Entity + 1 .. Main_Entity + Functions.Count);
   function Is_Local_Procedure (Name : Entity_Kind; Procedures : Procedure_Metadata) return Boolean is
     (Name in Procedure_Entity_Base + 1 .. Procedure_Entity_Base + Procedures.Count);
   function Is_Local_Subprogram
     (Name : Entity_Kind; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Is_Local_Function (Name, Functions) or else Is_Local_Procedure (Name, Procedures));
   function Is_Application_Entity
     (Name : Entity_Kind; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Name = Main_Entity or else Is_Local_Subprogram (Name, Functions, Procedures));

   function Entity_File (Name : Entity_Kind) return String is
     (case Name is
        when IO_Package | Put_Line | Put => Atom_silver_io_ads,
        when Libc_Package | Put_Byte | Flush | Set_Exit_Status => Atom_silver_output_libc_ads,
        when Arguments_Package | Input_Is_Valid | First_Or_Default | Reject => Atom_silver_arguments_ads,
        when Is_Message => Atom_silver_arguments_adb,
        when Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status => Atom_silver_runtime_ads,
        when Main_Entity .. Entity_Kind'Last => Atom_main_adb,
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

   function Fold (C : Character) return Character is
     (if C in 'A' .. 'Z' then Character'Val (Character'Pos (C) + 32) else C);

   function Source_Name_Valid
     (Source : String; Item : Function_Bindings.Signature) return Boolean is
     (Source'First = 1 and then Source'Length <= 4_096 and then Item.First >= 1 and then Item.First < Item.After
      and then Item.After <= Source'Length + 1);

   function Function_Spelling
     (Text : String; Name : Span; Source : String;
      Item : Function_Bindings.Signature) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;
   function Function_Spelling
     (Text : String; Name : Span; Source : String;
      Item : Function_Bindings.Signature) return Boolean is
     (Source_Name_Valid (Source, Item) and then Valid (Text, Name)
      and then Name.Last - Name.First = Item.After - Item.First + 6
      and then Text (Name.First) = '"' and then Text (Name.Last) = '"'
      and then Fold (Text (Name.First + 1)) = 'm'
      and then Fold (Text (Name.First + 2)) = 'a'
      and then Fold (Text (Name.First + 3)) = 'i'
      and then Fold (Text (Name.First + 4)) = 'n'
      and then Text (Name.First + 5) = '.'
      and then (for all I in Item.First .. Item.After - 1 =>
        Fold (Text (Name.First + 6 + I - Item.First)) = Fold (Source (I))));

   function Function_Name_Model
     (Text : String; Name : Span; Source : String; Functions : Function_Metadata;
      Count : Function_Bindings.Function_Count) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Count <= Functions.Count,
       Post => Function_Name_Model'Result = Unknown
         or else Function_Name_Model'Result in Main_Entity + 1 .. Main_Entity + Count,
       Subprogram_Variant => (Decreases => Count);
   function Function_Name_Model
     (Text : String; Name : Span; Source : String; Functions : Function_Metadata;
      Count : Function_Bindings.Function_Count) return Entity_Kind is
     (if Count = 0 then Unknown
      elsif Function_Spelling (Text, Name, Source, Functions.Items (Count)) then Main_Entity + Count
      else Function_Name_Model (Text, Name, Source, Functions, Count - 1));

   function Function_Name
     (Text : String; Name : Span; Source : String; Functions : Function_Metadata) return Entity_Kind
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Function_Name'Result =
         Function_Name_Model (Text, Name, Source, Functions, Functions.Count))
   is
      Count : Function_Bindings.Function_Count := Functions.Count;
   begin
      while Count > 0 loop
         pragma Loop_Invariant (Count <= Functions.Count);
         pragma Loop_Invariant (Static =>
           Function_Name_Model (Text, Name, Source, Functions, Functions.Count) =
           Function_Name_Model (Text, Name, Source, Functions, Count));
         pragma Loop_Variant (Decreases => Count);
         if Function_Spelling (Text, Name, Source, Functions.Items (Count)) then
            return Main_Entity + Count;
         end if;
         Count := Count - 1;
      end loop;
      return Unknown;
   end Function_Name;

   function Source_Name_Valid
     (Source : String; Item : Procedure_Bindings.Signature) return Boolean is
     (Source'First = 1 and then Source'Length <= 4_096 and then Item.First >= 1 and then Item.First < Item.After
      and then Item.After <= Source'Length + 1);

   function Procedure_Spelling
     (Text : String; Name : Span; Source : String;
      Item : Procedure_Bindings.Signature) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;
   function Procedure_Spelling
     (Text : String; Name : Span; Source : String;
      Item : Procedure_Bindings.Signature) return Boolean is
     (Source_Name_Valid (Source, Item) and then Valid (Text, Name)
      and then Name.Last - Name.First = Item.After - Item.First + 6
      and then Text (Name.First) = '"' and then Text (Name.Last) = '"'
      and then Fold (Text (Name.First + 1)) = 'm'
      and then Fold (Text (Name.First + 2)) = 'a'
      and then Fold (Text (Name.First + 3)) = 'i'
      and then Fold (Text (Name.First + 4)) = 'n'
      and then Text (Name.First + 5) = '.'
      and then (for all I in Item.First .. Item.After - 1 =>
        Fold (Text (Name.First + 6 + I - Item.First)) = Fold (Source (I))));

   function Procedure_Name_Model
     (Text : String; Name : Span; Source : String; Procedures : Procedure_Metadata;
      Count : Procedure_Bindings.Procedure_Count) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Count <= Procedures.Count,
       Post => Procedure_Name_Model'Result = Unknown
         or else Procedure_Name_Model'Result in Procedure_Entity_Base + 1 .. Procedure_Entity_Base + Count,
       Subprogram_Variant => (Decreases => Count);
   function Procedure_Name_Model
     (Text : String; Name : Span; Source : String; Procedures : Procedure_Metadata;
      Count : Procedure_Bindings.Procedure_Count) return Entity_Kind is
     (if Count = 0 then Unknown
      elsif Procedure_Spelling (Text, Name, Source, Procedures.Items (Count)) then Procedure_Entity_Base + Count
      else Procedure_Name_Model (Text, Name, Source, Procedures, Count - 1));

   function Procedure_Name
     (Text : String; Name : Span; Source : String; Procedures : Procedure_Metadata) return Entity_Kind
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Procedure_Name'Result =
         Procedure_Name_Model (Text, Name, Source, Procedures, Procedures.Count))
   is
      Count : Procedure_Bindings.Procedure_Count := Procedures.Count;
   begin
      while Count > 0 loop
         pragma Loop_Invariant (Count <= Procedures.Count);
         pragma Loop_Invariant (Static =>
           Procedure_Name_Model (Text, Name, Source, Procedures, Procedures.Count) =
           Procedure_Name_Model (Text, Name, Source, Procedures, Count));
         pragma Loop_Variant (Decreases => Count);
         if Procedure_Spelling (Text, Name, Source, Procedures.Items (Count)) then
            return Procedure_Entity_Base + Count;
         end if;
         Count := Count - 1;
      end loop;
      return Unknown;
   end Procedure_Name;

   function Termination_Message
     (Name : Entity_Kind; Source : String; Functions : Function_Metadata) return String is
     (if not Is_Local_Function (Name, Functions) then ""
      elsif not Source_Name_Valid (Source, Functions.Items (Name - Main_Entity)) then ""
      else "implicit aspect Always_Terminates on \""" &
        Source (Functions.Items (Name - Main_Entity).First ..
          Functions.Items (Name - Main_Entity).After - 1) &
        "\"" has been proved, subprogram will terminate");

   function Entity_Name_Spec (Text : String; Entity : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Entity_Name_Spec (Text : String; Entity : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind is
     (declare Name : constant Span := Field_Spec (Text, Entity, JSON_name);
              Kind : constant Entity_Kind := (
          if Main_Spelling (Text, Name) then Main_Entity
          elsif String_Equal (Text, Name, Atom_Silver_IO) then IO_Package
          elsif String_Equal (Text, Name, Atom_Silver_IO_Put_Line) then Put_Line
          elsif String_Equal (Text, Name, Atom_Silver_IO_Put) then Put
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
          else (if Function_Name_Model (Text, Name, Source, Functions, Functions.Count) /= Unknown then Function_Name_Model (Text, Name, Source, Functions, Functions.Count)
           else Procedure_Name_Model (Text, Name, Source, Procedures, Procedures.Count)));
      begin (if Location_Policy (Text, Entity, Kind) then Kind else Unknown));

   function Entity_Name (Text : String; Entity : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Entity_Name'Result = Entity_Name_Spec (Text, Entity, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      Name : constant Span := Field (Text, Entity, JSON_name);
      Result : Entity_Kind;
   begin
      if Main_Spelling (Text, Name) then Result := Main_Entity;
      elsif String_Equal (Text, Name, Atom_Silver_IO) then Result := IO_Package;
      elsif String_Equal (Text, Name, Atom_Silver_IO_Put_Line) then Result := Put_Line;
      elsif String_Equal (Text, Name, Atom_Silver_IO_Put) then Result := Put;
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
      else
         Result := Function_Name (Text, Name, Source => Source, Functions => Functions);
         if Result = Unknown then Result := Procedure_Name (Text, Name, Source, Procedures); end if;
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

   function Reference_Policy (Text : String; Entities, Reference : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Reference_Policy (Text : String; Entities, Reference : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (((String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_POST) and then Entity_Name_Spec (Text, Referenced_Entity_Spec
        (Text, Entities, Field_Spec (Text, Reference, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures) <= Main_Entity)
       or else String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_AORTE)
       or else String_Equal (Text, Field_Spec (Text, Reference, JSON_predicate), Atom_CLAIM_EFFECTS))
      and then Entity_Name_Spec (Text, Referenced_Entity_Spec
        (Text, Entities, Field_Spec (Text, Reference, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown);

   function Reference_OK (Text : String; Entities, Reference : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Reference_OK'Result = Reference_Policy (Text, Entities, Reference, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      Predicate : constant Span := Field (Text, Reference, JSON_predicate);
      Entity : constant Span := Referenced_Entity
        (Text, Entities, Field (Text, Reference, JSON_arg));
   begin
      return ((String_Equal (Text, Predicate, Atom_CLAIM_POST)
               and then Entity_Name (Text, Entity, Source => Source, Functions => Functions, Procedures => Procedures) <= Main_Entity)
              or else String_Equal (Text, Predicate, Atom_CLAIM_AORTE)
              or else String_Equal (Text, Predicate, Atom_CLAIM_EFFECTS))
        and then Entity_Name (Text, Entity, Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown;
   end Reference_OK;

   --  This advisory describes an unused initialized value, not a failed safety
   --  obligation. Its exact GNAT message contains one Ada name.
   function Initializer_Message (Text : String; Item : Span; Unused_Formal : Boolean := False) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Initializer_Message (Text : String; Item : Span; Unused_Formal : Boolean := False) return Boolean is
     (declare Prefix : constant String :=
        (if Unused_Formal then Unused_Formal_Prefix else Initialization_Prefix);
              Suffix : constant String :=
        (if Unused_Formal then Unused_Formal_Suffix else Initialization_Suffix);
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

   function Output_Message (Text : String; Item : Span) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Output_Message (Text : String; Item : Span) return Boolean is
     (String_Equal (Text, Item, Atom_unused_Written_Count)
      or else String_Equal (Text, Item, Atom_unused_Flushed)
      or else String_Equal (Text, Item, Atom_unused_Succeeded)
      or else String_Equal (Text, Item, Atom_unused_Written_Bytes)
      or else String_Equal (Text, Item, Atom_put_unused_Written_Count)
      or else String_Equal (Text, Item, Atom_put_unused_Flushed)
      or else String_Equal (Text, Item, Atom_put_unused_Succeeded)
      or else String_Equal (Text, Item, Atom_put_unused_Written_Bytes));

   --  All typed metadata is handled, including empty and malformed slices.
   --  Source membership supplies the stronger contiguous-pool invariant.
   function Output_Formal
     (Name : Entity_Kind; Index : Procedure_Bindings.Formal_Count;
      Procedures : Procedure_Metadata) return Boolean is
     (Is_Local_Procedure (Name, Procedures)
      and then Index in 1 .. Procedures.Parameter_Count
      and then Procedures.Parameters (Index).Mode = Procedure_Bindings.Output
      and then
        (declare Item : constant Procedure_Bindings.Signature :=
           Procedures.Items (Name - Procedure_Entity_Base);
         begin Item.Formal_First > 0 and then Item.Formal_First <= Procedures.Parameter_Count
           and then Item.Count > 0
           and then Item.Count <= Procedures.Parameter_Count - Item.Formal_First + 1
           and then Index >= Item.Formal_First and then Index - Item.Formal_First < Item.Count));

   function Required_Output
     (Index : Procedure_Bindings.Formal_Count; Procedures : Procedure_Metadata) return Boolean is
     (for some P in 1 .. Procedures.Count =>
        Output_Formal (Procedure_Entity_Base + P, Index, Procedures));

   function Source_Name_Valid
     (Source : String; Item : Procedure_Bindings.Formal) return Boolean is
     (Source'First = 1 and then Source'Length <= 4_096 and then Item.First >= 1 and then Item.First < Item.After
      and then Item.After <= Source'Length + 1);

   function Initialization_Message
     (Source : String; Item : Procedure_Bindings.Formal) return String is
     (if not Source_Name_Valid (Source, Item) then ""
      else "initialization of \""" & Source (Item.First .. Item.After - 1) & "\"" proved");

   function Initialization_Index_Model
     (Text : String; Message : Span; Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind; Count : Procedure_Bindings.Formal_Count) return Procedure_Bindings.Formal_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Count <= Procedures.Parameter_Count,
       Post => Initialization_Index_Model'Result <= Count,
       Subprogram_Variant => (Decreases => Count);
   function Initialization_Index_Model
     (Text : String; Message : Span; Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind; Count : Procedure_Bindings.Formal_Count) return Procedure_Bindings.Formal_Count is
     (if Count = 0 then 0
      elsif Output_Formal (Name, Count, Procedures)
        and then Source_Name_Valid (Source, Procedures.Parameters (Count))
        and then String_Equal (Text, Message, Initialization_Message (Source, Procedures.Parameters (Count)))
      then Count
      else Initialization_Index_Model (Text, Message, Source, Procedures, Name, Count - 1));

   function Initialization_Index
     (Text : String; Message : Span; Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind) return Procedure_Bindings.Formal_Count
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Initialization_Index'Result = Initialization_Index_Model
         (Text, Message, Source, Procedures, Name, Procedures.Parameter_Count))
   is
      Count : Procedure_Bindings.Formal_Count := Procedures.Parameter_Count;
   begin
      while Count > 0 loop
         pragma Loop_Invariant (Count <= Procedures.Parameter_Count);
         pragma Loop_Invariant (Static =>
           Initialization_Index_Model (Text, Message, Source, Procedures, Name, Procedures.Parameter_Count) =
           Initialization_Index_Model (Text, Message, Source, Procedures, Name, Count));
         pragma Loop_Variant (Decreases => Count);
         if Output_Formal (Name, Count, Procedures)
           and then Source_Name_Valid (Source, Procedures.Parameters (Count))
           and then String_Equal (Text, Message, Initialization_Message (Source, Procedures.Parameters (Count)))
         then return Count; end if;
         Count := Count - 1;
      end loop;
      return 0;
   end Initialization_Index;

   subtype List_Kind is Natural range
     0 .. 10 + Function_Bindings.Max_Functions + Procedure_Bindings.Max_Formals;
   Checks : constant List_Kind := 0;
   Main_Checks : constant List_Kind := 1;
   Binding_Diagnostics : constant List_Kind := 2;
   Argument_Diagnostics : constant List_Kind := 3;
   Assignment_Diagnostics : constant List_Kind := 4;
   Selected_Diagnostics : constant List_Kind := 5;
   Main_Advisories : constant List_Kind := 6;
   References : constant List_Kind := 7;
   Postconditions : constant List_Kind := 8;
   Put_Postconditions : constant List_Kind := 9;
   Argument_Postconditions : constant List_Kind := 10;
   subtype Termination_Witness is List_Kind range 11 .. 10 + Function_Bindings.Max_Functions;
   Initialization_Witness_Base : constant List_Kind := Termination_Witness'Last;
   subtype Initialization_Witness is List_Kind range Initialization_Witness_Base + 1 .. List_Kind'Last;
   subtype Exact_Witness is List_Kind range Termination_Witness'First .. Initialization_Witness'Last;

   subtype Main_Diagnostics is List_Kind range Binding_Diagnostics .. Selected_Diagnostics;
   function Termination_Policy (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;
   function Termination_Policy (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare Name : constant Entity_Kind := Entity_Name_Spec
        (Text, Referenced_Entity_Spec (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
      begin Is_Local_Function (Name, Functions)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_info)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then String_Equal
          (Text, Field_Spec (Text, Field_Spec (Text, Item, JSON_message), JSON_text),
           Termination_Message (Name, Source => Source, Functions => Functions))
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_suppressed) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing);

   function Termination_OK (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Termination_OK'Result = Termination_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      Name : constant Entity_Kind := Entity_Name
        (Text, Referenced_Entity (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
   begin
      return Is_Local_Function (Name, Functions)
        and then String_Equal (Text, Field (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
        and then String_Equal (Text, Field (Text, Item, JSON_severity), Atom_info)
        and then String_Equal (Text, Field (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then String_Equal
          (Text, Field (Text, Field (Text, Item, JSON_message), JSON_text),
           Termination_Message (Name, Source => Source, Functions => Functions))
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_suppressed) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing;
   end Termination_OK;

   function Initialization_Policy (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;
   function Initialization_Policy (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare Name : constant Entity_Kind := Entity_Name_Spec
        (Text, Referenced_Entity_Spec (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
      begin Initialization_Index_Model
          (Text, Field_Spec (Text, Field_Spec (Text, Item, JSON_message), JSON_text),
           Source, Procedures, Name, Procedures.Parameter_Count) > 0
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_UNINITIALIZED)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_info)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_suppressed) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing);

   function Initialization_OK (Text : String; Item, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Initialization_OK'Result = Initialization_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      Name : constant Entity_Kind := Entity_Name
        (Text, Referenced_Entity (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
   begin
      return Initialization_Index
          (Text, Field (Text, Field (Text, Item, JSON_message), JSON_text),
           Source, Procedures, Name) > 0
        and then String_Equal (Text, Field (Text, Item, JSON_rule), Atom_UNINITIALIZED)
        and then String_Equal (Text, Field (Text, Item, JSON_severity), Atom_info)
        and then String_Equal (Text, Field (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_suppressed) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing;
   end Initialization_OK;

   function Record_Policy (Text : String; Item, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Record_Policy (Text : String; Item, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean is
     (if Kind = References then Reference_Policy (Text, Entities, Item, Source => Source, Functions => Functions, Procedures => Procedures)
      elsif Kind in Termination_Witness then
        String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
        and then Entity_Name_Spec (Text, Referenced_Entity_Spec
          (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
            Main_Entity + Kind - Argument_Postconditions
      elsif Kind in Initialization_Witness then
        String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_UNINITIALIZED)
        and then Initialization_Index_Model
          (Text, Field_Spec (Text, Field_Spec (Text, Item, JSON_message), JSON_text), Source, Procedures,
           Entity_Name_Spec (Text, Referenced_Entity_Spec (Text, Entities, Field_Spec (Text, Item, JSON_entity)),
             Source => Source, Functions => Functions, Procedures => Procedures), Procedures.Parameter_Count) =
          Kind - Initialization_Witness_Base
      elsif Kind = Main_Advisories then
        String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), Atom_trivial)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then
          ((String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_imprecise_image)
            and then Image_Message (Text, Field_Spec
              (Text, Field_Spec (Text, Item, JSON_message), JSON_text)))
           or else
             (String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_array_initialization)
              and then String_Equal (Text, Field_Spec
                (Text, Field_Spec (Text, Item, JSON_message), JSON_text), Atom_array_initialization_message)))
        and then String_Equal (Text, Field_Spec
          (Text, Field_Spec (Text, Item, JSON_unproved_status), JSON_status), Atom_unknown)
        and then Empty_Object_Spec (Text, Field_Spec (Text, Item, JSON_check_tree))
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_suppressed), Atom_Empty)
        and then Field_Spec (Text, Item, JSON_entity) = Missing
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing
      elsif Kind in Main_Diagnostics then
        Termination_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
        Initialization_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
        (String_Equal (Text, Field_Spec (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_line))
        and then Positive_Number (Text, Field_Spec (Text, Item, JSON_col))
        and then Is_Application_Entity (Entity_Name_Spec (Text, Referenced_Entity_Spec
          (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
        and then
          ((String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_UNUSED_VARIABLE)
            and then Is_Local_Subprogram (Entity_Name_Spec (Text, Referenced_Entity_Spec
              (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
            and then Initializer_Message (Text, Field_Spec
              (Text, Field_Spec (Text, Item, JSON_message), JSON_text), True))
           or else (String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_INEFFECTIVE)
            and then
              (Initializer_Message (Text, Field_Spec
                 (Text, Field_Spec (Text, Item, JSON_message), JSON_text))
               or else Output_Message (Text, Field_Spec
                 (Text, Field_Spec (Text, Item, JSON_message), JSON_text))
               or else (Kind in Assignment_Diagnostics | Selected_Diagnostics
                 and then String_Equal (Text, Field_Spec
                   (Text, Field_Spec (Text, Item, JSON_message), JSON_text), Atom_unused_assignment))
               or else (String_Equal (Text, Field_Spec
                   (Text, Field_Spec (Text, Item, JSON_message), JSON_text), Atom_statement_no_effect))))
           or else (String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_DEAD_CODE)
             and then String_Equal (Text, Field_Spec
               (Text, Field_Spec (Text, Item, JSON_message), JSON_text), Atom_statement_unreachable)))
        and then Field_Spec (Text, Item, JSON_justification) = Missing
        and then Field_Spec (Text, Item, JSON_justified) = Missing
        and then Field_Spec (Text, Item, JSON_suppressed) = Missing
        and then Field_Spec (Text, Item, JSON_annot_kind) = Missing
        and then Field_Spec (Text, Item, JSON_justif_msg) = Missing)
      elsif Kind in Postconditions | Put_Postconditions | Argument_Postconditions then
        String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_POSTCONDITION)
        and then Entity_Name_Spec (Text, Referenced_Entity_Spec
          (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
            (if Kind = Postconditions then Put_Line
             elsif Kind = Put_Postconditions then Put else First_Or_Default)
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
             and then (String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_RANGE_CHECK)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_LENGTH_CHECK)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_OVERFLOW_CHECK)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_DIVISION_CHECK)
               or else String_Equal (Text, Field_Spec (Text, Item, JSON_rule), Atom_VC_INDEX_CHECK))
             and then String_Equal (Text, Field_Spec (Text, Item, JSON_file), Atom_main_adb)
             and then Is_Application_Entity (Entity_Name_Spec (Text, Referenced_Entity_Spec
               (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
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
               (Text, Entities, Field_Spec (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown));

   function Record_OK
     (Text : String; Item, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Record_OK'Result = Record_Policy (Text, Item, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      How : Span;
   begin
      if Kind = References then return Reference_OK (Text, Entities, Item, Source => Source, Functions => Functions, Procedures => Procedures); end if;
      if Kind in Termination_Witness then
         return String_Equal (Text, Field (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
           and then Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
               Main_Entity + Kind - Argument_Postconditions;
      end if;
      if Kind in Initialization_Witness then
         return String_Equal (Text, Field (Text, Item, JSON_rule), Atom_UNINITIALIZED)
           and then Initialization_Index
             (Text, Field (Text, Field (Text, Item, JSON_message), JSON_text), Source, Procedures,
              Entity_Name (Text, Referenced_Entity (Text, Entities, Field (Text, Item, JSON_entity)),
                Source => Source, Functions => Functions, Procedures => Procedures)) =
             Kind - Initialization_Witness_Base;
      end if;
      if Kind = Main_Advisories then
         return String_Equal (Text, Field (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field (Text, Item, JSON_how_proved), Atom_trivial)
        and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then
          ((String_Equal (Text, Field (Text, Item, JSON_rule), Atom_imprecise_image)
            and then Image_Message (Text, Field
              (Text, Field (Text, Item, JSON_message), JSON_text)))
           or else
             (String_Equal (Text, Field (Text, Item, JSON_rule), Atom_array_initialization)
              and then String_Equal (Text, Field
                (Text, Field (Text, Item, JSON_message), JSON_text), Atom_array_initialization_message)))
        and then String_Equal (Text, Field
          (Text, Field (Text, Item, JSON_unproved_status), JSON_status), Atom_unknown)
        and then Empty_Object (Text, Field (Text, Item, JSON_check_tree))
        and then String_Equal (Text, Field (Text, Item, JSON_suppressed), Atom_Empty)
        and then Field (Text, Item, JSON_entity) = Missing
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing;
      end if;
      if Kind in Main_Diagnostics then
         return Termination_OK (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
           Initialization_OK (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
        (String_Equal (Text, Field (Text, Item, JSON_severity), Atom_warning)
        and then String_Equal (Text, Field (Text, Item, JSON_how_proved), JSON_flow)
        and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
        and then Positive_Number (Text, Field (Text, Item, JSON_line))
        and then Positive_Number (Text, Field (Text, Item, JSON_col))
        and then Is_Application_Entity (Entity_Name (Text, Referenced_Entity
          (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
        and then
          ((String_Equal (Text, Field (Text, Item, JSON_rule), Atom_UNUSED_VARIABLE)
            and then Is_Local_Subprogram (Entity_Name (Text, Referenced_Entity
              (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
            and then Initializer_Message (Text, Field
              (Text, Field (Text, Item, JSON_message), JSON_text), True))
           or else (String_Equal (Text, Field (Text, Item, JSON_rule), Atom_INEFFECTIVE)
            and then
              (Initializer_Message (Text, Field
                 (Text, Field (Text, Item, JSON_message), JSON_text))
               or else Output_Message (Text, Field
                 (Text, Field (Text, Item, JSON_message), JSON_text))
               or else (Kind in Assignment_Diagnostics | Selected_Diagnostics
                 and then String_Equal (Text, Field
                   (Text, Field (Text, Item, JSON_message), JSON_text), Atom_unused_assignment))
               or else (String_Equal (Text, Field
                   (Text, Field (Text, Item, JSON_message), JSON_text), Atom_statement_no_effect))))
           or else (String_Equal (Text, Field (Text, Item, JSON_rule), Atom_DEAD_CODE)
             and then String_Equal (Text, Field
               (Text, Field (Text, Item, JSON_message), JSON_text), Atom_statement_unreachable)))
        and then Field (Text, Item, JSON_justification) = Missing
        and then Field (Text, Item, JSON_justified) = Missing
        and then Field (Text, Item, JSON_suppressed) = Missing
        and then Field (Text, Item, JSON_annot_kind) = Missing
        and then Field (Text, Item, JSON_justif_msg) = Missing);
      end if;

      if Kind in Postconditions | Put_Postconditions | Argument_Postconditions then
         return String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_POSTCONDITION)
           and then Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures)
                = (if Kind = Postconditions then Put_Line
                   elsif Kind = Put_Postconditions then Put else First_Or_Default);
      end if;
      How := Field (Text, Item, JSON_how_proved);
      if Kind = Main_Checks then
         return String_Equal (Text, Field (Text, Item, JSON_severity), Atom_info)
           and then String_Equal (Text, How, Atom_prover)
           and then (String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_RANGE_CHECK)
             or else String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_LENGTH_CHECK)
             or else String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_OVERFLOW_CHECK)
             or else String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_DIVISION_CHECK)
             or else String_Equal (Text, Field (Text, Item, JSON_rule), Atom_VC_INDEX_CHECK))
           and then String_Equal (Text, Field (Text, Item, JSON_file), Atom_main_adb)
           and then Positive_Number (Text, Field (Text, Item, JSON_line))
           and then Positive_Number (Text, Field (Text, Item, JSON_col))
           and then Is_Application_Entity (Entity_Name (Text, Referenced_Entity
             (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
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
          (Text, Entities, Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown;
   end Record_OK;

   type List_Summary is record
      Well_Formed : Boolean;
      Every_OK : Boolean;
      Has_OK : Boolean;
   end record;

   function List_From
     (Text : String; Items, Entities : Span; Kind : List_Kind; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return List_Summary
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function List_From
     (Text : String; Items, Entities : Span; Kind : List_Kind; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return List_Summary is
     (declare M : constant Member := Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => (False, False, False),
           when Finished => (True, True, False),
           when Present =>
             (declare Rest : constant List_Summary :=
                 List_From (Text, Items, Entities, Kind, M.Next, Source => Source, Functions => Functions, Procedures => Procedures);
                      Good : constant Boolean := Record_Policy (Text, M.Value, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
              begin (Rest.Well_Formed and (Kind not in Exact_Witness or else not (Good and Rest.Has_OK)),
                     Good and Rest.Every_OK, Good or Rest.Has_OK))));

   function List_Policy (Summary : List_Summary; Kind : List_Kind;
                         Found : Boolean := False) return Boolean
     with Ghost => Static, Global => null;

   function List_Policy (Summary : List_Summary; Kind : List_Kind;
                         Found : Boolean := False) return Boolean is
     (Summary.Well_Formed and then
        (if Kind in Postconditions | Put_Postconditions | Argument_Postconditions | Exact_Witness
         then (Found or Summary.Has_OK)
           and then (Kind not in Exact_Witness or else not (Found and Summary.Has_OK))
         else Summary.Every_OK));

   function List_Spec
     (Text : String; Items, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function List_Spec
     (Text : String; Items, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '['
        and then Text (Items.Last) = ']'
        and then List_Policy (List_From (Text, Items, Entities, Kind, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures), Kind));

   function List_OK
     (Text : String; Items, Entities : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => List_OK'Result = List_Spec (Text, Items, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
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
           (Static => List_Spec (Text, Items, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures) =
             List_Policy (List_From (Text, Items, Entities, Kind, P, Source => Source, Functions => Functions, Procedures => Procedures), Kind, Found));
         pragma Loop_Variant (Increases => P);
         M := Read_Item (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished =>
               return Kind not in Postconditions | Put_Postconditions | Argument_Postconditions | Exact_Witness or else Found;
            when Present =>
               if Kind in Postconditions | Put_Postconditions | Argument_Postconditions | Exact_Witness then
                  if Record_OK (Text, M.Value, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures) then
                     if Kind in Exact_Witness and then Found then return False; end if;
                     Found := True;
                  end if;
               elsif not Record_OK (Text, M.Value, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures) then
                  return False;
               end if;
               P := M.Next;
         end case;
      end loop;
   end List_OK;

   function Dependencies_From
     (Text : String; Items, Entities : Span; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Dependencies_From
     (Text : String; Items, Entities : Span; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare M : constant Member := Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => False,
           when Finished => True,
           when Present =>
             Reference_Policy (Text, Entities, Field_Spec (Text, M.Value, JSON_claim), Source => Source, Functions => Functions, Procedures => Procedures)
             and then List_Spec
               (Text, Field_Spec (Text, M.Value, JSON_assumptions), Entities, References, Source => Source, Functions => Functions, Procedures => Procedures)
             and then Dependencies_From (Text, Items, Entities, M.Next, Source => Source, Functions => Functions, Procedures => Procedures)));

   function Dependencies_Spec (Text : String; Items, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Dependencies_Spec (Text : String; Items, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '['
      and then Text (Items.Last) = ']'
      and then Dependencies_From (Text, Items, Entities, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures));

   function Dependencies_OK
     (Text : String; Items, Entities : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Dependencies_OK'Result = Dependencies_Spec (Text, Items, Entities, Source => Source, Functions => Functions, Procedures => Procedures))
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
           (Static => Dependencies_Spec (Text, Items, Entities, Source => Source, Functions => Functions, Procedures => Procedures) =
             Dependencies_From (Text, Items, Entities, P, Source => Source, Functions => Functions, Procedures => Procedures));
         pragma Loop_Variant (Increases => P);
         M := Read_Item (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished => return True;
            when Present =>
               if not Reference_OK (Text, Entities, Field (Text, M.Value, JSON_claim), Source => Source, Functions => Functions, Procedures => Procedures)
                 or else not List_OK
                   (Text, Field (Text, M.Value, JSON_assumptions), Entities, References, Source => Source, Functions => Functions, Procedures => Procedures)
               then return False; end if;
               P := M.Next;
         end case;
      end loop;
   end Dependencies_OK;

   function Expected_Entity (Name : Entity_Kind; Kind : Audit_Kind;
      Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean is
     ((Kind in Application_Audit and then
        Is_Local_Subprogram (Name, Functions, Procedures)) or else
      (case Kind is
        when IO_Body => Name in IO_Package | Put_Line | Put | Put_Byte | Flush | Set_Exit_Status,
        when Libc_Interface => Name in Libc_Package | Put_Byte | Flush | Set_Exit_Status,
        when Argument_Body => Name in Arguments_Package | Input_Is_Valid | First_Or_Default
          | Reject | Is_Message | Set_Exit_Status | Argument_Count | Argument,
        when Argv_Interface => Name in Runtime_Package | Argument_Count | Argument | Runtime_Exit_Status,
        when Main_Body | Selected_Main =>
          Name in Main_Entity | First_Or_Default | Input_Is_Valid | Reject | Put_Line,
        when Main_Put | Selected_Put =>
          Name in Main_Entity | First_Or_Default | Input_Is_Valid | Reject | Put,
        when Main_Mixed | Selected_Mixed =>
          Name in Main_Entity | First_Or_Default | Input_Is_Valid | Reject | Put_Line | Put,
        when Argument_Without_Query | Selected_Without_Query =>
          Name in Main_Entity | First_Or_Default | Reject | Put_Line,
        when Argument_Put_Without_Query | Selected_Put_Without_Query =>
          Name in Main_Entity | First_Or_Default | Reject | Put,
        when Argument_Mixed_Without_Query | Selected_Mixed_Without_Query =>
          Name in Main_Entity | First_Or_Default | Reject | Put_Line | Put,
        when Argument_Effects_Without_Query | Selected_Effects_Without_Query =>
          Name in Main_Entity | First_Or_Default | Reject,
        when Argument_Effects | Selected_Effects =>
          Name in Main_Entity | First_Or_Default | Input_Is_Valid | Reject,
        when Binding_Main | Argument_Binding_Main | Assignment_Main | Selected_Binding_Main =>
          Name = Main_Entity,
        when Static_Main | Assignment_Effects => Name in Main_Entity | Put_Line,
        when Static_Put | Assignment_Put => Name in Main_Entity | Put,
        when Static_Mixed | Assignment_Mixed => Name in Main_Entity | Put_Line | Put));

   function Expected_Coverage (Name : Entity_Kind; Kind : Audit_Kind;
      Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return String is
     (case Kind is
        when IO_Body => (if Name in IO_Package | Put_Line | Put then Atom_all else Atom_Empty),
        when Libc_Interface =>
          (if Name = Libc_Package then Atom_all
           elsif Name in Put_Byte | Flush | Set_Exit_Status then Atom_spec else Atom_Empty),
        when Argument_Body =>
          (if Name in Arguments_Package | Input_Is_Valid | First_Or_Default | Reject | Is_Message
           then Atom_all else Atom_Empty),
        when Argv_Interface =>
          (if Name = Runtime_Package then Atom_all
           elsif Name in Argument_Count | Argument | Runtime_Exit_Status then Atom_spec else Atom_Empty),
        when Application_Audit =>
          (if Is_Application_Entity (Name, Functions, Procedures) then Atom_all else Atom_Empty));

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
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then M.State = Present and then Valid (Text, M.Key)
         and then Valid (Text, M.Value);

   function Map_Name (Text : String; Items, Entities : Span; M : Member;
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind is
     (if M.Key.Last - M.Key.First < 1 then Unknown
      elsif Coverage then
        (declare Name : constant Entity_Kind := Entity_Name_Spec
            (Text, Field_Spec (Text, Entities, Text (M.Key.First + 1 .. M.Key.Last - 1)), Source => Source, Functions => Functions, Procedures => Procedures);
         begin
           (if Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length = 0
              or else not String_Equal (Text, M.Value, Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures))
            then Unknown else Name))
      elsif Field_Spec (Text, Items, Text (M.Key.First + 1 .. M.Key.Last - 1)) /= M.Value
      then Unknown
      else Entity_Name_Spec (Text, M.Value, Source => Source, Functions => Functions, Procedures => Procedures));

   function Map_From (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Entity_Summary
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Items)
         and then Position in Items.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Map_From (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Entity_Summary is
     (declare M : constant Member := Member_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Broken => (False, False, No_Entities),
           when Finished => (True, True, No_Entities),
           when Present =>
             (declare Name : constant Entity_Kind := Map_Name (Text, Items, Entities, M, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures);
                      Rest : constant Entity_Summary := Map_From (Text, Items, Entities, Kind, Coverage, M.Next, Source => Source, Functions => Functions, Procedures => Procedures);
              begin
                (Rest.Well_Formed and Name /= Unknown,
                 Rest.Unique and not Rest.Seen (Name),
                 Remember (Rest.Seen, Name)))));

   function Map_Policy (Prefix : Entity_Set; Suffix : Entity_Summary;
                        Kind : Audit_Kind; Coverage : Boolean;
      Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Map_Policy (Prefix : Entity_Set; Suffix : Entity_Summary;
                        Kind : Audit_Kind; Coverage : Boolean;
      Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Suffix.Well_Formed and then Suffix.Unique
      and then (for all Name in Entity_Kind =>
        not (Prefix (Name) and Suffix.Seen (Name))
        and ((Prefix (Name) or Suffix.Seen (Name)) =
          (if Coverage then Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length > 0
           else Expected_Entity (Name, Kind, Functions => Functions, Procedures => Procedures)))));

   --  A name can move from the recursively specified suffix to the
   --  imperative prefix without changing uniqueness or exact coverage.
   procedure Advance_Map
     (Prefix : Entity_Set; Rest : Entity_Summary; Name : Entity_Kind;
      Kind : Audit_Kind; Coverage : Boolean;
      Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Name /= Unknown and then not Prefix (Name),
       Post => Map_Policy
         (Prefix, (Rest.Well_Formed, Rest.Unique and not Rest.Seen (Name),
                   Remember (Rest.Seen, Name)), Kind, Coverage, Functions => Functions, Procedures => Procedures) =
         Map_Policy (Remember (Prefix, Name), Rest, Kind, Coverage, Functions => Functions, Procedures => Procedures)
   is
   begin
      null;
   end Advance_Map;

   procedure Finish_Map
     (Prefix : Entity_Set; Kind : Audit_Kind; Coverage : Boolean;
      Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Post => Map_Policy
         (Prefix, (True, True, No_Entities), Kind, Coverage, Functions => Functions, Procedures => Procedures) =
         (for all Name in Entity_Kind => Prefix (Name) =
           (if Coverage then Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length > 0
            else Expected_Entity (Name, Kind, Functions => Functions, Procedures => Procedures)))
   is
   begin
      null;
   end Finish_Map;

   function Map_Spec (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Map_Spec (Text : String; Items, Entities : Span;
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Valid (Text, Items) and then Text (Items.First) = '{'
      and then Text (Items.Last) = '}'
      and then Map_Policy
        (No_Entities, Map_From (Text, Items, Entities, Kind, Coverage, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures), Kind, Coverage, Functions => Functions, Procedures => Procedures));

   function Map_OK (Text : String; Items, Entities : Span;
                    Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Map_OK'Result = Map_Spec (Text, Items, Entities, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures))
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
           (Static => Map_Spec (Text, Items, Entities, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures) =
             Map_Policy (Seen, Map_From (Text, Items, Entities, Kind, Coverage, P, Source => Source, Functions => Functions, Procedures => Procedures), Kind, Coverage, Functions => Functions, Procedures => Procedures));
         pragma Loop_Variant (Increases => P);
         M := Read_Member (Text, Items, P);
         case M.State is
            when Broken => return False;
            when Finished =>
               pragma Assert (Static => Map_From
                 (Text, Items, Entities, Kind, Coverage, P, Source => Source, Functions => Functions, Procedures => Procedures) =
                   (True, True, No_Entities));
               Finish_Map (Seen, Kind, Coverage, Functions => Functions, Procedures => Procedures);
               exit;
            when Present =>
               if M.Key.Last - M.Key.First < 1 then return False; end if;
               if Coverage then
                  Name := Entity_Name (Text, Field
                    (Text, Entities, Text (M.Key.First + 1 .. M.Key.Last - 1)), Source => Source, Functions => Functions, Procedures => Procedures);
                  if Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length = 0
                    or else not String_Equal (Text, M.Value, Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures))
                  then return False; end if;
               else
                  if Field (Text, Items, Text (M.Key.First + 1 .. M.Key.Last - 1)) /= M.Value
                  then return False; end if;
                  Name := Entity_Name (Text, M.Value, Source => Source, Functions => Functions, Procedures => Procedures);
               end if;
               pragma Assert
                 (Static => Name = Map_Name (Text, Items, Entities, M, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures));
               if Name = Unknown or else Seen (Name) then
                  pragma Assert (Static => not Map_Spec (Text, Items, Entities, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures));
                  return False;
               end if;
               declare
                  Rest : constant Entity_Summary := Map_From
                    (Text, Items, Entities, Kind, Coverage, M.Next, Source => Source, Functions => Functions, Procedures => Procedures)
                    with Ghost => Static;
               begin
                  pragma Assert
                    (Static => Map_From (Text, Items, Entities, Kind, Coverage, P, Source => Source, Functions => Functions, Procedures => Procedures) =
                      (Rest.Well_Formed, Rest.Unique and not Rest.Seen (Name),
                       Remember (Rest.Seen, Name)));
                  Advance_Map (Seen, Rest, Name, Kind, Coverage, Functions => Functions, Procedures => Procedures);
                  pragma Assert
                    (Static => Map_Policy
                      (Seen, Map_From (Text, Items, Entities, Kind, Coverage, P, Source => Source, Functions => Functions, Procedures => Procedures), Kind, Coverage, Functions => Functions, Procedures => Procedures) =
                      Map_Policy (Remember (Seen, Name), Rest, Kind, Coverage, Functions => Functions, Procedures => Procedures));
               end;
               Seen := Remember (Seen, Name);
               P := M.Next;
         end case;
      end loop;
      return (for all Name in Entity_Kind => Seen (Name) =
        (if Coverage then Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length > 0
         else Expected_Entity (Name, Kind, Functions => Functions, Procedures => Procedures)));
   end Map_OK;

   function Entities_OK (Text : String; Entities : Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Entities_OK'Result = Map_Spec (Text, Entities, Entities, Kind, False, Source => Source, Functions => Functions, Procedures => Procedures))
   is
   begin
      return Map_OK (Text, Entities, Entities, Kind, False, Source => Source, Functions => Functions, Procedures => Procedures);
   end Entities_OK;

   function Coverage_OK (Text : String; Coverage, Entities : Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => (Static => Coverage_OK'Result = Map_Spec (Text, Coverage, Entities, Kind, True, Source => Source, Functions => Functions, Procedures => Procedures))
   is
   begin
      return Map_OK (Text, Coverage, Entities, Kind, True, Source => Source, Functions => Functions, Procedures => Procedures);
   end Coverage_OK;

   --  Policy over byte-derived fields. Array folds state universal discharge
   --  and an existential owned-postcondition witness; map folds establish
   --  uniqueness and exactly the required entity and coverage sets. None of
   --  these definitions invokes Audit_Report or its executable traversal loops.
   function Object_Policy (Text : String; Object : Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Object_Policy (Text : String; Object : Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean is
     (declare Entities : constant Span := Field_Spec (Text, Object, JSON_entities);
      begin
        String_Equal (Text, Field_Spec (Text, Object, JSON_progress), Atom_PROGRESS_PROOF)
        and then String_Equal (Text, Field_Spec (Text, Object, JSON_stop_reason), Atom_STOP_REASON_NONE)
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_skip_flow_proof))
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_skip_proof))
        and then Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_pragma_assume))
        and then (if Kind in Application_Audit then
          List_Spec (Text, Field_Spec (Text, Object, JSON_warn_error), Entities, Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures)
          else Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_warn_error)))
        and then Map_Spec (Text, Entities, Entities, Kind, False, Source => Source, Functions => Functions, Procedures => Procedures)
        and then Map_Spec (Text, Field_Spec (Text, Object, JSON_spark), Entities, Kind, True, Source => Source, Functions => Functions, Procedures => Procedures)
        and then List_Spec (Text, Field_Spec (Text, Object, JSON_flow), Entities,
          (if Kind in Main_Body | Main_Put | Main_Mixed | Argument_Effects | Argument_Binding_Main
                 | Argument_Without_Query | Argument_Put_Without_Query | Argument_Mixed_Without_Query
                 | Argument_Effects_Without_Query then Argument_Diagnostics
           elsif Kind in Selected_Main | Selected_Put | Selected_Mixed | Selected_Effects | Selected_Binding_Main
                 | Selected_Without_Query | Selected_Put_Without_Query | Selected_Mixed_Without_Query
                 | Selected_Effects_Without_Query then Selected_Diagnostics
           elsif Kind in Mutable_Audit then Assignment_Diagnostics
           elsif Kind in Application_Audit then Binding_Diagnostics else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
        and then List_Spec (Text, Field_Spec (Text, Object, JSON_proof), Entities,
                           (if Kind in Application_Audit then Main_Checks else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
        and then (if Kind in Application_Audit then
          (for all I in 1 .. Functions.Count => List_Spec
            (Text, Field_Spec (Text, Object, JSON_flow), Entities, Argument_Postconditions + I, Source => Source, Functions => Functions, Procedures => Procedures)) and then
          (for all I in 1 .. Procedures.Parameter_Count =>
             (if Required_Output (I, Procedures) then List_Spec
               (Text, Field_Spec (Text, Object, JSON_flow), Entities, Initialization_Witness_Base + I,
                Source => Source, Functions => Functions, Procedures => Procedures))))
        and then Dependencies_Spec (Text, Field_Spec (Text, Object, JSON_assumptions), Entities, Source => Source, Functions => Functions, Procedures => Procedures)
        and then (Kind in Libc_Interface | Argv_Interface | Application_Audit or else
          (not Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_flow))
           and then not Empty_Array_Spec (Text, Field_Spec (Text, Object, JSON_proof))
           and then List_Spec (Text, Field_Spec (Text, Object, JSON_proof), Entities,
             (if Kind = IO_Body then Postconditions else Argument_Postconditions), Source => Source, Functions => Functions, Procedures => Procedures)
           and then (if Kind = IO_Body then List_Spec
             (Text, Field_Spec (Text, Object, JSON_proof), Entities, Put_Postconditions, Source => Source, Functions => Functions, Procedures => Procedures)))));

   function Report_Policy (Report : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Report_Policy (Report : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Report'Length in 1 .. Max_Report_Length and then
       (declare Text : constant String (1 .. Report'Length) := Report;
                Start : constant Offset := Space_End (Text, 1);
                Last : constant Offset := Value_Spec (Text, Start);
        begin
          Last /= 0 and then Space_End (Text, Last + 1) = Text'Length + 1
            and then Object_Policy (Text, (Start, Last), Kind, Source => Source, Functions => Functions, Procedures => Procedures)));

   --  Uncapped audit observations are functions of the original byte sequence.
   --  Their definitions do not call projection, bounded acceptance, or an
   --  executable audit loop. Only the projected representation has a capacity.
   package Raw_Scan renames Silver_Report_Observations;
   package Raw_Bytes renames Raw_Scan.Bytes;
   use type SPARK.Big_Integers.Big_Integer;
   use type Raw_Scan.Span;
   use type Raw_Scan.Member_State;

   function Raw_String_Equal
     (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span; Expected : String) return Boolean is
     (Raw_Scan.Valid (Text, Item)
      and then Item.Last - Item.First = SPARK.Big_Integers.To_Big_Integer (Expected'Length) + 1
      and then Raw_Bytes.Get (Text, Item.First) = '"'
      and then Raw_Bytes.Get (Text, Item.Last) = '"'
      and then (for all I in Expected'Range =>
        Raw_Bytes.Get (Text, Item.First + 1 + SPARK.Big_Integers.To_Big_Integer (I - Expected'First)) =
          Expected (I)))
     with Ghost => Static;

   function Raw_Image_Message
     (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_String_Equal (Text, Item, Atom_image_message)
      or else Raw_String_Equal (Text, Item, Atom_image_message_lower)
      or else Raw_String_Equal (Text, Item, Atom_image_message_upper))
     with Ghost => Static;

   function Raw_Merge_Field (Left, Right : Raw_Scan.Span) return Raw_Scan.Span is
     (if Left = Raw_Scan.Malformed or else Right = Raw_Scan.Malformed then Raw_Scan.Malformed
      elsif Left = Raw_Scan.Missing then Right
      elsif Right = Raw_Scan.Missing then Left else Raw_Scan.Malformed)
     with Ghost => Static;

   function Raw_Field_From
     (Text : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Name : String;
      Position : Raw_Scan.Offset) return Raw_Scan.Span
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Text, Object)
         and then Position >= Object.First + 1
         and then Position <= Raw_Bytes.Length (Text) + 1,
       Post => Raw_Field_From'Result = Raw_Scan.Missing
         or else Raw_Field_From'Result = Raw_Scan.Malformed
         or else Raw_Scan.Valid (Text, Raw_Field_From'Result),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Text) + 1 - Position);

   function Raw_Field_From
     (Text : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Name : String;
      Position : Raw_Scan.Offset) return Raw_Scan.Span is
     (declare M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Text, Object, Position);
      begin
        (case M.State is
           when Raw_Scan.Broken => Raw_Scan.Malformed,
           when Raw_Scan.Finished => Raw_Scan.Missing,
           when Raw_Scan.Present => Raw_Merge_Field
             ((if Raw_String_Equal (Text, M.Key, Name) then M.Value else Raw_Scan.Missing),
              Raw_Field_From (Text, Object, Name, M.Next))));

   function Raw_Field
     (Text : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Name : String) return Raw_Scan.Span is
     (if not Raw_Scan.Valid (Text, Object)
        or else Raw_Bytes.Get (Text, Object.First) /= '{'
        or else Raw_Bytes.Get (Text, Object.Last) /= '}' then Raw_Scan.Malformed
      else Raw_Field_From (Text, Object, Name, Object.First + 1))
     with Ghost => Static;

   --  Dynamic entity identifiers stay raw byte spans, even when their source
   --  position or length cannot be represented by a machine-sized String.
   function Raw_Name_Range (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span) return Boolean is
     (Name.First >= 1 and then Name.First <= Name.Last + 1
      and then Name.Last <= Raw_Bytes.Length (Text))
     with Ghost => Static;

   function Raw_Key_Equal
     (Text : Raw_Bytes.Sequence; Key, Name : Raw_Scan.Span; Padded : Boolean) return Boolean is
     (Raw_Scan.Valid (Text, Key) and then Raw_Name_Range (Text, Name)
      and then Key.Last - Key.First = Name.Last + 1 - Name.First + SPARK.Big_Integers.To_Big_Integer (if Padded then 2 else 1)
      and then Raw_Bytes.Get (Text, Key.First) = '"'
      and then Raw_Bytes.Get (Text, Key.Last) = '"'
      and then (not Padded or else Raw_Bytes.Get (Text, Key.First + 1) = ' ')
      and then (for all I in Text =>
        (if I >= Name.First and then I <= Name.Last then
           Raw_Bytes.Get (Text, Key.First + SPARK.Big_Integers.To_Big_Integer (if Padded then 2 else 1) + I - Name.First) =
             Raw_Bytes.Get (Text, I))))
     with Ghost => Static;

   function Raw_Field_Key_From
     (Text : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span;
      Padded : Boolean; Position : Raw_Scan.Offset) return Raw_Scan.Span
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Text, Object) and then Raw_Name_Range (Text, Name)
         and then Position >= Object.First + 1
         and then Position <= Raw_Bytes.Length (Text) + 1,
       Post => Raw_Field_Key_From'Result = Raw_Scan.Missing
         or else Raw_Field_Key_From'Result = Raw_Scan.Malformed
         or else Raw_Scan.Valid (Text, Raw_Field_Key_From'Result),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Text) + 1 - Position);

   function Raw_Field_Key_From
     (Text : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span;
      Padded : Boolean; Position : Raw_Scan.Offset) return Raw_Scan.Span is
     (declare M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Text, Object, Position);
      begin
        (case M.State is
           when Raw_Scan.Broken => Raw_Scan.Malformed,
           when Raw_Scan.Finished => Raw_Scan.Missing,
           when Raw_Scan.Present => Raw_Merge_Field
             ((if Raw_Key_Equal (Text, M.Key, Name, Padded) then M.Value else Raw_Scan.Missing),
              Raw_Field_Key_From (Text, Object, Name, Padded, M.Next))));

   function Raw_Field_Key
     (Text : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span;
      Padded : Boolean := False) return Raw_Scan.Span is
     (if not Raw_Scan.Valid (Text, Object) or else not Raw_Name_Range (Text, Name)
        or else Raw_Bytes.Get (Text, Object.First) /= '{'
        or else Raw_Bytes.Get (Text, Object.Last) /= '}' then Raw_Scan.Malformed
      else Raw_Field_Key_From (Text, Object, Name, Padded, Object.First + 1))
     with Ghost => Static;

   function Raw_Empty_Object (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_Scan.Valid (Text, Item) and then Raw_Bytes.Get (Text, Item.First) = '{'
      and then Raw_Bytes.Get (Text, Item.Last) = '}'
      and then Raw_Scan.Space_End (Text, Item.First + 1) = Item.Last)
     with Ghost => Static;

   function Raw_Empty_Array (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_Scan.Valid (Text, Item) and then Raw_Bytes.Get (Text, Item.First) = '['
      and then Raw_Bytes.Get (Text, Item.Last) = ']'
      and then Raw_Scan.Space_End (Text, Item.First + 1) = Item.Last)
     with Ghost => Static;

   function Raw_Location
     (Text : Raw_Bytes.Sequence; Entity : Raw_Scan.Span; Name : Entity_Kind) return Boolean is
     (Name /= Unknown and then
       (declare Locations : constant Raw_Scan.Span := Raw_Field (Text, Entity, JSON_sloc);
        begin
          Raw_Scan.Valid (Text, Locations) and then Raw_Bytes.Get (Text, Locations.First) = '['
            and then Raw_Bytes.Get (Text, Locations.Last) = ']'
            and then
              (declare P : constant Raw_Scan.Offset := Raw_Scan.Space_End (Text, Locations.First + 1);
                       L : constant Raw_Scan.Offset := Raw_Scan.Value_Spec (Text, P);
               begin L /= 0 and then L < Locations.Last
                 and then Raw_Scan.Space_End (Text, L + 1) = Locations.Last
                 and then Raw_String_Equal
                   (Text, Raw_Field (Text, (P, L), JSON_file), Entity_File (Name)))))
     with Ghost => Static;

   function Raw_Main_Spelling (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span) return Boolean is
     (Raw_Scan.Valid (Text, Name) and then Name.Last - Name.First = 5
      and then Raw_Bytes.Get (Text, Name.First) = '"' and then Raw_Bytes.Get (Text, Name.Last) = '"'
      and then Raw_Bytes.Get (Text, Name.First + 1) in 'm' | 'M'
      and then Raw_Bytes.Get (Text, Name.First + 2) in 'a' | 'A'
      and then Raw_Bytes.Get (Text, Name.First + 3) in 'i' | 'I'
      and then Raw_Bytes.Get (Text, Name.First + 4) in 'n' | 'N')
     with Ghost => Static;

   function Raw_Function_Spelling
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String;
      Item : Function_Bindings.Signature) return Boolean is
     (Source_Name_Valid (Source, Item) and then Raw_Scan.Valid (Text, Name)
      and then Name.Last - Name.First = To_Big_Integer (Item.After - Item.First) + 6
      and then Raw_Bytes.Get (Text, Name.First) = '"'
      and then Raw_Bytes.Get (Text, Name.Last) = '"'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 1)) = 'm'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 2)) = 'a'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 3)) = 'i'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 4)) = 'n'
      and then Raw_Bytes.Get (Text, Name.First + 5) = '.'
      and then (for all I in Item.First .. Item.After - 1 =>
        Fold (Raw_Bytes.Get (Text, Name.First + 6 + To_Big_Integer (I - Item.First))) = Fold (Source (I))))
     with Ghost => Static;

   function Raw_Function_Name
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String; Functions : Function_Metadata;
      Count : Function_Bindings.Function_Count) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Count <= Functions.Count,
       Post => Raw_Function_Name'Result = Unknown
         or else Raw_Function_Name'Result in Main_Entity + 1 .. Main_Entity + Count,
       Subprogram_Variant => (Decreases => Count);
   function Raw_Function_Name
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String; Functions : Function_Metadata;
      Count : Function_Bindings.Function_Count) return Entity_Kind is
     (if Count = 0 then Unknown
      elsif Raw_Function_Spelling (Text, Name, Source, Functions.Items (Count)) then Main_Entity + Count
      else Raw_Function_Name (Text, Name, Source, Functions, Count - 1));

   function Raw_Procedure_Spelling
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String;
      Item : Procedure_Bindings.Signature) return Boolean is
     (Source_Name_Valid (Source, Item) and then Raw_Scan.Valid (Text, Name)
      and then Name.Last - Name.First = To_Big_Integer (Item.After - Item.First) + 6
      and then Raw_Bytes.Get (Text, Name.First) = '"'
      and then Raw_Bytes.Get (Text, Name.Last) = '"'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 1)) = 'm'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 2)) = 'a'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 3)) = 'i'
      and then Fold (Raw_Bytes.Get (Text, Name.First + 4)) = 'n'
      and then Raw_Bytes.Get (Text, Name.First + 5) = '.'
      and then (for all I in Item.First .. Item.After - 1 =>
        Fold (Raw_Bytes.Get (Text, Name.First + 6 + To_Big_Integer (I - Item.First))) = Fold (Source (I))))
     with Ghost => Static;

   function Raw_Procedure_Name
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String; Procedures : Procedure_Metadata;
      Count : Procedure_Bindings.Procedure_Count) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => Count <= Procedures.Count,
       Post => Raw_Procedure_Name'Result = Unknown
         or else Raw_Procedure_Name'Result in Procedure_Entity_Base + 1 .. Procedure_Entity_Base + Count,
       Subprogram_Variant => (Decreases => Count);
   function Raw_Procedure_Name
     (Text : Raw_Bytes.Sequence; Name : Raw_Scan.Span; Source : String; Procedures : Procedure_Metadata;
      Count : Procedure_Bindings.Procedure_Count) return Entity_Kind is
     (if Count = 0 then Unknown
      elsif Raw_Procedure_Spelling (Text, Name, Source, Procedures.Items (Count)) then Procedure_Entity_Base + Count
      else Raw_Procedure_Name (Text, Name, Source, Procedures, Count - 1));

   function Raw_Entity_Name (Text : Raw_Bytes.Sequence; Entity : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind
     with Ghost => Static, Global => null;

   function Raw_Entity_Name (Text : Raw_Bytes.Sequence; Entity : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind is
     (declare Name : constant Raw_Scan.Span := Raw_Field (Text, Entity, JSON_name);
              Kind : constant Entity_Kind := (
          if Raw_Main_Spelling (Text, Name) then Main_Entity
          elsif Raw_String_Equal (Text, Name, Atom_Silver_IO) then IO_Package
          elsif Raw_String_Equal (Text, Name, Atom_Silver_IO_Put_Line) then Put_Line
          elsif Raw_String_Equal (Text, Name, Atom_Silver_IO_Put) then Put
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Output_Libc) then Libc_Package
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Output_Libc_Put_Byte) then Put_Byte
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Output_Libc_Flush) then Flush
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Output_Libc_Set_Exit_Status) then Set_Exit_Status
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Arguments) then Arguments_Package
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Arguments_Input_Is_Valid) then Input_Is_Valid
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Arguments_First_Or_Default) then First_Or_Default
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Arguments_Reject) then Reject
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Arguments_Is_Message) then Is_Message
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Runtime) then Runtime_Package
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Runtime_Argument_Count) then Argument_Count
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Runtime_Argument) then Argument
          elsif Raw_String_Equal (Text, Name, Atom_Silver_Runtime_Set_Exit_Status) then Runtime_Exit_Status
          else (if Raw_Function_Name (Text, Name, Source, Functions, Functions.Count) /= Unknown then Raw_Function_Name (Text, Name, Source, Functions, Functions.Count)
           else Raw_Procedure_Name (Text, Name, Source, Procedures, Procedures.Count)));
      begin (if Raw_Location (Text, Entity, Kind) then Kind else Unknown));

   function Raw_Digits (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_Scan.Valid (Text, Item)
      and then (for all I in Text =>
        (if I >= Item.First and then I <= Item.Last then Raw_Bytes.Get (Text, I) in '0' .. '9')))
     with Ghost => Static;

   function Raw_Positive_Number (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_Digits (Text, Item)
      and then (for some I in Text =>
        I >= Item.First and then I <= Item.Last and then Raw_Bytes.Get (Text, I) /= '0'))
     with Ghost => Static;

   function Raw_Nonempty_String (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_Scan.Valid (Text, Item) and then Item.Last - Item.First > 1
      and then Raw_Bytes.Get (Text, Item.First) = '"'
      and then Raw_Bytes.Get (Text, Item.Last) = '"')
     with Ghost => Static;

   function Raw_Referenced_Entity
     (Text : Raw_Bytes.Sequence; Entities, Arg : Raw_Scan.Span) return Raw_Scan.Span is
     (if not Raw_Digits (Text, Arg) then Raw_Scan.Missing
      else (declare Padded : constant Raw_Scan.Span := Raw_Field_Key (Text, Entities, Arg, True);
            begin (if Padded = Raw_Scan.Missing then Raw_Field_Key (Text, Entities, Arg) else Padded)))
     with Ghost => Static;

   function Raw_Literal_At
     (Text : Raw_Bytes.Sequence; First : Raw_Scan.Offset; Expected : String) return Boolean is
     (First >= 1
      and then First - 1 + SPARK.Big_Integers.To_Big_Integer (Expected'Length) <= Raw_Bytes.Length (Text)
      and then (for all I in Expected'Range =>
        Raw_Bytes.Get (Text, First + SPARK.Big_Integers.To_Big_Integer (I - Expected'First)) = Expected (I)))
     with Ghost => Static;

   function Raw_Initializer_Message (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span; Unused_Formal : Boolean := False) return Boolean is
     (declare Prefix : constant String :=
        (if Unused_Formal then Unused_Formal_Prefix else Initialization_Prefix);
              Suffix : constant String :=
        (if Unused_Formal then Unused_Formal_Suffix else Initialization_Suffix);
              PL : constant Raw_Scan.Offset := SPARK.Big_Integers.To_Big_Integer (Prefix'Length);
              SL : constant Raw_Scan.Offset := SPARK.Big_Integers.To_Big_Integer (Suffix'Length);
      begin Raw_Scan.Valid (Text, Item)
        and then Item.Last - Item.First + 1 > PL + SL
        and then Item.Last - Item.First + 1 <= PL + SL + 4_096
        and then Raw_Literal_At (Text, Item.First, Prefix)
        and then Raw_Literal_At (Text, Item.Last - SL + 1, Suffix)
        and then Raw_Bytes.Get (Text, Item.First + PL) in 'A' .. 'Z' | 'a' .. 'z'
        and then Raw_Bytes.Get (Text, Item.Last - SL) /= '_'
        and then (for all I in Text =>
          (if I >= Item.First + PL and then I <= Item.Last - SL then
             Raw_Bytes.Get (Text, I) in 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_'
             and then (if Raw_Bytes.Get (Text, I) = '_' then Raw_Bytes.Get (Text, I - 1) /= '_'))))
     with Ghost => Static;

   function Raw_Reference_Policy (Text : Raw_Bytes.Sequence; Entities, Reference : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Raw_Reference_Policy (Text : Raw_Bytes.Sequence; Entities, Reference : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (((Raw_String_Equal (Text, Raw_Field (Text, Reference, JSON_predicate), Atom_CLAIM_POST) and then Raw_Entity_Name (Text, Raw_Referenced_Entity
        (Text, Entities, Raw_Field (Text, Reference, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures) <= Main_Entity)
       or else Raw_String_Equal (Text, Raw_Field (Text, Reference, JSON_predicate), Atom_CLAIM_AORTE)
       or else Raw_String_Equal (Text, Raw_Field (Text, Reference, JSON_predicate), Atom_CLAIM_EFFECTS))
      and then Raw_Entity_Name (Text, Raw_Referenced_Entity
        (Text, Entities, Raw_Field (Text, Reference, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown);

   function Raw_Output_Message (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean
     with Ghost => Static, Global => null;

   function Raw_Output_Message (Text : Raw_Bytes.Sequence; Item : Raw_Scan.Span) return Boolean is
     (Raw_String_Equal (Text, Item, Atom_unused_Written_Count)
      or else Raw_String_Equal (Text, Item, Atom_unused_Flushed)
      or else Raw_String_Equal (Text, Item, Atom_unused_Succeeded)
      or else Raw_String_Equal (Text, Item, Atom_unused_Written_Bytes)
      or else Raw_String_Equal (Text, Item, Atom_put_unused_Written_Count)
      or else Raw_String_Equal (Text, Item, Atom_put_unused_Flushed)
      or else Raw_String_Equal (Text, Item, Atom_put_unused_Succeeded)
      or else Raw_String_Equal (Text, Item, Atom_put_unused_Written_Bytes));

   function Raw_Initialization_Index
     (Text : Raw_Bytes.Sequence; Message : Raw_Scan.Span; Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind; Count : Procedure_Bindings.Formal_Count) return Procedure_Bindings.Formal_Count
     with Ghost => Static, Global => null,
       Pre => Count <= Procedures.Parameter_Count,
       Post => Raw_Initialization_Index'Result <= Count,
       Subprogram_Variant => (Decreases => Count);
   function Raw_Initialization_Index
     (Text : Raw_Bytes.Sequence; Message : Raw_Scan.Span; Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind; Count : Procedure_Bindings.Formal_Count) return Procedure_Bindings.Formal_Count is
     (if Count = 0 then 0
      elsif Output_Formal (Name, Count, Procedures)
        and then Source_Name_Valid (Source, Procedures.Parameters (Count))
        and then Raw_String_Equal (Text, Message, Initialization_Message (Source, Procedures.Parameters (Count)))
      then Count
      else Raw_Initialization_Index (Text, Message, Source, Procedures, Name, Count - 1));

   function Raw_Termination_Policy (Text : Raw_Bytes.Sequence; Item, Entities : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare Name : constant Entity_Kind := Raw_Entity_Name
        (Text, Raw_Referenced_Entity (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
      begin Is_Local_Function (Name, Functions)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_severity), Atom_info)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), JSON_flow)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_main_adb)
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_line))
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_col))
        and then Raw_String_Equal
          (Text, Raw_Field (Text, Raw_Field (Text, Item, JSON_message), JSON_text),
           Termination_Message (Name, Source => Source, Functions => Functions))
        and then Raw_Field (Text, Item, JSON_justification) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justified) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_suppressed) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_annot_kind) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justif_msg) = Raw_Scan.Missing)
     with Ghost => Static;

   function Raw_Initialization_Policy (Text : Raw_Bytes.Sequence; Item, Entities : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare Name : constant Entity_Kind := Raw_Entity_Name
        (Text, Raw_Referenced_Entity (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
      begin Raw_Initialization_Index
          (Text, Raw_Field (Text, Raw_Field (Text, Item, JSON_message), JSON_text),
           Source, Procedures, Name, Procedures.Parameter_Count) > 0
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_UNINITIALIZED)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_severity), Atom_info)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), JSON_flow)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_main_adb)
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_line))
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_col))
        and then Raw_Field (Text, Item, JSON_justification) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justified) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_suppressed) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_annot_kind) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justif_msg) = Raw_Scan.Missing)
     with Ghost => Static;

   function Raw_Record_Policy (Text : Raw_Bytes.Sequence; Item, Entities : Raw_Scan.Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean
     with Ghost => Static, Global => null;

   function Raw_Record_Policy (Text : Raw_Bytes.Sequence; Item, Entities : Raw_Scan.Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean is
     (if Kind = References then Raw_Reference_Policy (Text, Entities, Item, Source => Source, Functions => Functions, Procedures => Procedures)
      elsif Kind in Termination_Witness then
        Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_SUBPROGRAM_TERMINATION)
        and then Raw_Entity_Name (Text, Raw_Referenced_Entity
          (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
            Main_Entity + Kind - Argument_Postconditions
      elsif Kind in Initialization_Witness then
        Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_UNINITIALIZED)
        and then Raw_Initialization_Index
          (Text, Raw_Field (Text, Raw_Field (Text, Item, JSON_message), JSON_text), Source, Procedures,
           Raw_Entity_Name (Text, Raw_Referenced_Entity (Text, Entities, Raw_Field (Text, Item, JSON_entity)),
             Source => Source, Functions => Functions, Procedures => Procedures), Procedures.Parameter_Count) =
          Kind - Initialization_Witness_Base
      elsif Kind = Main_Advisories then
        Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_severity), Atom_warning)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), Atom_trivial)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_main_adb)
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_line))
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_col))
        and then
          ((Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_imprecise_image)
            and then Raw_Image_Message (Text, Raw_Field
              (Text, Raw_Field (Text, Item, JSON_message), JSON_text)))
           or else
             (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_array_initialization)
              and then Raw_String_Equal (Text, Raw_Field
                (Text, Raw_Field (Text, Item, JSON_message), JSON_text), Atom_array_initialization_message)))
        and then Raw_String_Equal (Text, Raw_Field
          (Text, Raw_Field (Text, Item, JSON_unproved_status), JSON_status), Atom_unknown)
        and then Raw_Empty_Object (Text, Raw_Field (Text, Item, JSON_check_tree))
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_suppressed), Atom_Empty)
        and then Raw_Field (Text, Item, JSON_entity) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justification) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justified) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_annot_kind) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justif_msg) = Raw_Scan.Missing
      elsif Kind in Main_Diagnostics then
        Raw_Termination_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
        Raw_Initialization_Policy (Text, Item, Entities, Source => Source, Functions => Functions, Procedures => Procedures) or else
        (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_severity), Atom_warning)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), JSON_flow)
        and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_main_adb)
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_line))
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_col))
        and then Is_Application_Entity (Raw_Entity_Name (Text, Raw_Referenced_Entity
          (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
        and then
          ((Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_UNUSED_VARIABLE)
            and then Is_Local_Subprogram (Raw_Entity_Name (Text, Raw_Referenced_Entity
              (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
            and then Raw_Initializer_Message (Text, Raw_Field
              (Text, Raw_Field (Text, Item, JSON_message), JSON_text), True))
           or else (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_INEFFECTIVE)
            and then
              (Raw_Initializer_Message (Text, Raw_Field
                 (Text, Raw_Field (Text, Item, JSON_message), JSON_text))
               or else Raw_Output_Message (Text, Raw_Field
                 (Text, Raw_Field (Text, Item, JSON_message), JSON_text))
               or else (Kind in Assignment_Diagnostics | Selected_Diagnostics
                 and then Raw_String_Equal (Text, Raw_Field
                   (Text, Raw_Field (Text, Item, JSON_message), JSON_text), Atom_unused_assignment))
               or else (Raw_String_Equal (Text, Raw_Field
                   (Text, Raw_Field (Text, Item, JSON_message), JSON_text), Atom_statement_no_effect))))
           or else (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_DEAD_CODE)
             and then Raw_String_Equal (Text, Raw_Field
               (Text, Raw_Field (Text, Item, JSON_message), JSON_text), Atom_statement_unreachable)))
        and then Raw_Field (Text, Item, JSON_justification) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justified) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_suppressed) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_annot_kind) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justif_msg) = Raw_Scan.Missing)
      elsif Kind in Postconditions | Put_Postconditions | Argument_Postconditions then
        Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_POSTCONDITION)
        and then Raw_Entity_Name (Text, Raw_Referenced_Entity
          (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
            (if Kind = Postconditions then Put_Line
             elsif Kind = Put_Postconditions then Put else First_Or_Default)
      else
        Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_severity), Atom_info)
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_line))
        and then Raw_Positive_Number (Text, Raw_Field (Text, Item, JSON_col))
        and then Raw_Field (Text, Item, JSON_justification) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justified) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_suppressed) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_annot_kind) = Raw_Scan.Missing
        and then Raw_Field (Text, Item, JSON_justif_msg) = Raw_Scan.Missing
        and then
          (if Kind = Main_Checks then
             Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), Atom_prover)
             and then (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_RANGE_CHECK)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_LENGTH_CHECK)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_OVERFLOW_CHECK)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_DIVISION_CHECK)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_rule), Atom_VC_INDEX_CHECK))
             and then Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_main_adb)
             and then Is_Application_Entity (Raw_Entity_Name (Text, Raw_Referenced_Entity
               (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Functions, Procedures)
           else
             (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), JSON_flow)
              or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), Atom_prover)
              or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_how_proved), Atom_trivial))
             and then Raw_Nonempty_String (Text, Raw_Field (Text, Item, JSON_rule))
             and then (Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_io_ads)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_io_adb)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_output_libc_ads)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_arguments_ads)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_arguments_adb)
               or else Raw_String_Equal (Text, Raw_Field (Text, Item, JSON_file), Atom_silver_runtime_ads))
             and then Raw_Entity_Name (Text, Raw_Referenced_Entity
               (Text, Entities, Raw_Field (Text, Item, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) /= Unknown));

   function Raw_List_From
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Kind : List_Kind; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return List_Summary
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Text, Items)
         and then Position >= Items.First + 1 and then Position <= Raw_Bytes.Length (Text) + 1,
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Text) + 1) - Position);

   function Raw_List_From
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Kind : List_Kind; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return List_Summary is
     (declare M : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Raw_Scan.Broken => (False, False, False),
           when Raw_Scan.Finished => (True, True, False),
           when Raw_Scan.Present =>
             (declare Rest : constant List_Summary :=
                 Raw_List_From (Text, Items, Entities, Kind, M.Next, Source => Source, Functions => Functions, Procedures => Procedures);
                      Good : constant Boolean := Raw_Record_Policy (Text, M.Value, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
              begin (Rest.Well_Formed and (Kind not in Exact_Witness or else not (Good and Rest.Has_OK)),
                     Good and Rest.Every_OK, Good or Rest.Has_OK))));

   function Raw_List_Spec
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Raw_List_Spec
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Raw_Scan.Valid (Text, Items) and then Raw_Bytes.Get (Text, Items.First) = '['
        and then Raw_Bytes.Get (Text, Items.Last) = ']'
        and then List_Policy (Raw_List_From (Text, Items, Entities, Kind, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures), Kind));

   function Raw_Dependencies_From
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Text, Items)
         and then Position >= Items.First + 1 and then Position <= Raw_Bytes.Length (Text) + 1,
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Text) + 1) - Position);

   function Raw_Dependencies_From
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare M : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Raw_Scan.Broken => False,
           when Raw_Scan.Finished => True,
           when Raw_Scan.Present =>
             Raw_Reference_Policy (Text, Entities, Raw_Field (Text, M.Value, JSON_claim), Source => Source, Functions => Functions, Procedures => Procedures)
             and then Raw_List_Spec
               (Text, Raw_Field (Text, M.Value, JSON_assumptions), Entities, References, Source => Source, Functions => Functions, Procedures => Procedures)
             and then Raw_Dependencies_From (Text, Items, Entities, M.Next, Source => Source, Functions => Functions, Procedures => Procedures)));

   function Raw_Dependencies_Spec (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Raw_Dependencies_Spec (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Raw_Scan.Valid (Text, Items) and then Raw_Bytes.Get (Text, Items.First) = '['
      and then Raw_Bytes.Get (Text, Items.Last) = ']'
      and then Raw_Dependencies_From (Text, Items, Entities, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures));

   function Raw_Map_Name
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; M : Raw_Scan.Member;
      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind
     with Ghost => Static, Global => null,
       Pre => M.State = Raw_Scan.Present and then Raw_Scan.Valid (Text, M.Key)
         and then Raw_Scan.Valid (Text, M.Value);

   function Raw_Map_Name
     (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span; M : Raw_Scan.Member;
      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Entity_Kind is
     (if M.Key.Last - M.Key.First < 1 then Unknown
      elsif Coverage then
        (declare Name : constant Entity_Kind := Raw_Entity_Name
            (Text, Raw_Field_Key (Text, Entities, (M.Key.First + 1, M.Key.Last - 1)), Source => Source, Functions => Functions, Procedures => Procedures);
         begin
           (if Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures)'Length = 0
              or else not Raw_String_Equal (Text, M.Value, Expected_Coverage (Name, Kind, Functions => Functions, Procedures => Procedures))
            then Unknown else Name))
      elsif Raw_Field_Key (Text, Items, (M.Key.First + 1, M.Key.Last - 1)) /= M.Value
      then Unknown
      else Raw_Entity_Name (Text, M.Value, Source => Source, Functions => Functions, Procedures => Procedures));

   function Raw_Map_From (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Entity_Summary
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Text, Items)
         and then Position >= Items.First + 1 and then Position <= Raw_Bytes.Length (Text) + 1,
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Text) + 1) - Position);

   function Raw_Map_From (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
                      Kind : Audit_Kind; Coverage : Boolean; Position : Raw_Scan.Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Entity_Summary is
     (declare M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Text, Items, Position);
      begin
        (case M.State is
           when Raw_Scan.Broken => (False, False, No_Entities),
           when Raw_Scan.Finished => (True, True, No_Entities),
           when Raw_Scan.Present =>
             (declare Name : constant Entity_Kind := Raw_Map_Name (Text, Items, Entities, M, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures);
                      Rest : constant Entity_Summary := Raw_Map_From (Text, Items, Entities, Kind, Coverage, M.Next, Source => Source, Functions => Functions, Procedures => Procedures);
              begin
                (Rest.Well_Formed and Name /= Unknown,
                 Rest.Unique and not Rest.Seen (Name),
                 Remember (Rest.Seen, Name)))));

   function Raw_Map_Spec (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null;

   function Raw_Map_Spec (Text : Raw_Bytes.Sequence; Items, Entities : Raw_Scan.Span;
                      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Raw_Scan.Valid (Text, Items) and then Raw_Bytes.Get (Text, Items.First) = '{'
      and then Raw_Bytes.Get (Text, Items.Last) = '}'
      and then Map_Policy
        (No_Entities, Raw_Map_From (Text, Items, Entities, Kind, Coverage, Items.First + 1, Source => Source, Functions => Functions, Procedures => Procedures), Kind, Coverage, Functions => Functions, Procedures => Procedures));

   function Raw_Object_Policy (Text : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean
     with Ghost => Static, Global => null;

   function Raw_Object_Policy (Text : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     return Boolean is
     (declare Entities : constant Raw_Scan.Span := Raw_Field (Text, Object, JSON_entities);
      begin
        Raw_String_Equal (Text, Raw_Field (Text, Object, JSON_progress), Atom_PROGRESS_PROOF)
        and then Raw_String_Equal (Text, Raw_Field (Text, Object, JSON_stop_reason), Atom_STOP_REASON_NONE)
        and then Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_skip_flow_proof))
        and then Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_skip_proof))
        and then Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_pragma_assume))
        and then (if Kind in Application_Audit then
          Raw_List_Spec (Text, Raw_Field (Text, Object, JSON_warn_error), Entities, Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures)
          else Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_warn_error)))
        and then Raw_Map_Spec (Text, Entities, Entities, Kind, False, Source => Source, Functions => Functions, Procedures => Procedures)
        and then Raw_Map_Spec (Text, Raw_Field (Text, Object, JSON_spark), Entities, Kind, True, Source => Source, Functions => Functions, Procedures => Procedures)
        and then Raw_List_Spec (Text, Raw_Field (Text, Object, JSON_flow), Entities,
          (if Kind in Main_Body | Main_Put | Main_Mixed | Argument_Effects | Argument_Binding_Main
                 | Argument_Without_Query | Argument_Put_Without_Query | Argument_Mixed_Without_Query
                 | Argument_Effects_Without_Query then Argument_Diagnostics
           elsif Kind in Selected_Main | Selected_Put | Selected_Mixed | Selected_Effects | Selected_Binding_Main
                 | Selected_Without_Query | Selected_Put_Without_Query | Selected_Mixed_Without_Query
                 | Selected_Effects_Without_Query then Selected_Diagnostics
           elsif Kind in Mutable_Audit then Assignment_Diagnostics
           elsif Kind in Application_Audit then Binding_Diagnostics else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
        and then Raw_List_Spec (Text, Raw_Field (Text, Object, JSON_proof), Entities,
                           (if Kind in Application_Audit then Main_Checks else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
        and then (if Kind in Application_Audit then
          (for all I in 1 .. Functions.Count => Raw_List_Spec
            (Text, Raw_Field (Text, Object, JSON_flow), Entities, Argument_Postconditions + I, Source => Source, Functions => Functions, Procedures => Procedures)) and then
          (for all I in 1 .. Procedures.Parameter_Count =>
             (if Required_Output (I, Procedures) then Raw_List_Spec
               (Text, Raw_Field (Text, Object, JSON_flow), Entities, Initialization_Witness_Base + I,
                Source => Source, Functions => Functions, Procedures => Procedures))))
        and then Raw_Dependencies_Spec (Text, Raw_Field (Text, Object, JSON_assumptions), Entities, Source => Source, Functions => Functions, Procedures => Procedures)
        and then (Kind in Libc_Interface | Argv_Interface | Application_Audit or else
          (not Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_flow))
           and then not Raw_Empty_Array (Text, Raw_Field (Text, Object, JSON_proof))
           and then Raw_List_Spec (Text, Raw_Field (Text, Object, JSON_proof), Entities,
             (if Kind = IO_Body then Postconditions else Argument_Postconditions), Source => Source, Functions => Functions, Procedures => Procedures)
           and then (if Kind = IO_Body then Raw_List_Spec
             (Text, Raw_Field (Text, Object, JSON_proof), Entities, Put_Postconditions, Source => Source, Functions => Functions, Procedures => Procedures)))));

   function Raw_Report_Policy (Report : Raw_Bytes.Sequence; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare Start : constant Raw_Scan.Offset := Raw_Scan.Space_End (Report, 1);
              Last : constant Raw_Scan.Offset := Raw_Scan.Value_Spec (Report, Start);
      begin Last /= 0
        and then Raw_Scan.Space_End (Report, Last + 1) = Raw_Bytes.Length (Report) + 1
        and then Raw_Object_Policy (Report, (Start, Last), Kind, Source => Source, Functions => Functions, Procedures => Procedures))
     with Ghost => Static;

   function Unbounded_Runtime_Report_Policy
     (Report : Raw_Bytes.Sequence; Kind : Report_Kind) return Boolean is
     (Raw_Report_Policy (Report, Audit_Of (Kind), Atom_Empty, Empty_Functions, Empty_Procedures));

   function Unbounded_Application_Report_Policy
     (Report : Raw_Bytes.Sequence; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures) return Boolean is
     (case Kind is
        when Static_Output => Raw_Report_Policy (Report, Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Static_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Static_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Static_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Argument_Output => Raw_Report_Policy (Report, Argument_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Argument_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Main_Body, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Main_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Main_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Argument_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Argument_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Argument_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Argument_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures),
        when Assigned_Output => Raw_Report_Policy (Report, Assignment_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Assignment_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Assignment_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Assignment_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Selected_Output => Raw_Report_Policy (Report, Selected_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Raw_Report_Policy (Report, Selected_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures));

   --  This agreement is about field bytes and malformed/missing observations.
   --  Raw positions and the original sequence have no storage bound.
   function Mixed_Content
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span) return Boolean is
     (Text'First = 1 and then Raw_Scan.Valid (Raw, L) and then Valid (Text, R)
      and then L.Last - L.First = SPARK.Big_Integers.To_Big_Integer (R.Last - R.First)
      and then Raw_Scan.Window_Matches (Raw, L.First, Text (R.First .. R.Last)))
     with Ghost => Static;

   function Mixed_Field
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span) return Boolean is
     (if L = Raw_Scan.Missing then R = Missing
      elsif L = Raw_Scan.Malformed then R = Malformed
      else Mixed_Content (Raw, L, Text, R))
     with Ghost => Static;

   procedure Literal_Window_Congruence
     (Raw : Raw_Bytes.Sequence; First : Raw_Scan.Offset; Text, Expected : String)
     with Ghost => Static, Global => null,
       Pre => Text'Length = Expected'Length
         and then Raw_Scan.Window_Matches (Raw, First, Text),
       Post => Raw_Literal_At (Raw, First, Expected) = (Text = Expected)
   is
   begin
      if Text = Expected then
         pragma Assert (for all I in Expected'Range =>
           Raw_Bytes.Get (Raw, First + SPARK.Big_Integers.To_Big_Integer (I - Expected'First)) =
             Expected (I));
      elsif Raw_Literal_At (Raw, First, Expected) then
         for I in Text'Range loop
            pragma Assert (I - Text'First < Expected'Length);
            pragma Assert
              (Text (I) = Raw_Bytes.Get
                 (Raw, First + SPARK.Big_Integers.To_Big_Integer (I - Text'First)));
            pragma Assert (Text (I) = Expected (Expected'First + (I - Text'First)));
            pragma Loop_Invariant (for all J in Text'First .. I =>
              Text (J) = Expected (Expected'First + (J - Text'First)));
         end loop;
      end if;
   end Literal_Window_Congruence;

   procedure Mixed_String_Congruence
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Expected : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_String_Equal (Raw, L, Expected) = String_Equal (Text, R, Expected)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         pragma Assert (Raw_Bytes.Get (Raw, L.First) = Text (R.First));
         pragma Assert (Raw_Bytes.Get (Raw, L.Last) = Text (R.Last));
         if R.Last - R.First >= 1 and then (R.Last - R.First) - 1 = Expected'Length then
            pragma Assert (Raw_Scan.Window_Matches
              (Raw, L.First + 1, Text (R.First + 1 .. R.Last - 1)));
            Literal_Window_Congruence
              (Raw, L.First + 1, Text (R.First + 1 .. R.Last - 1), Expected);
         end if;
      end if;
   end Mixed_String_Congruence;

   procedure Mixed_Byte_Correspondence
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R),
       Post => (for all I in Raw =>
         (if I >= L.First and then I <= L.Last then
            I - L.First <= SPARK.Big_Integers.To_Big_Integer (R.Last - R.First)
            and then Raw_Bytes.Get (Raw, I) =
              Text (R.First + SPARK.Big_Integers.To_Integer (I - L.First))))
   is
   begin
      pragma Assert (for all I in Raw =>
        (if I >= L.First and then I <= L.Last then
           I - L.First <= SPARK.Big_Integers.To_Big_Integer (R.Last - R.First)));
   end Mixed_Byte_Correspondence;

   procedure Mixed_Basic_Tests
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Positive_Number (Raw, L) = Positive_Number (Text, R)
         and then Raw_Nonempty_String (Raw, L) = Nonempty_String (Text, R)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Byte_Correspondence (Raw, L, Text, R);
         pragma Assert (Raw_Bytes.Get (Raw, L.First) = Text (R.First));
         pragma Assert (Raw_Bytes.Get (Raw, L.Last) = Text (R.Last));
      end if;
   end Mixed_Basic_Tests;

   procedure Mixed_Output_Message
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Output_Message (Raw, L) = Output_Message (Text, R)
   is
   begin
      Mixed_String_Congruence (Raw, L, Text, R, Atom_unused_Written_Count);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_unused_Flushed);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_unused_Succeeded);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_unused_Written_Bytes);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_put_unused_Written_Count);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_put_unused_Flushed);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_put_unused_Succeeded);
      Mixed_String_Congruence (Raw, L, Text, R, Atom_put_unused_Written_Bytes);
   end Mixed_Output_Message;

   procedure Mixed_Initializer_Message
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Unused_Formal : Boolean := False)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Initializer_Message (Raw, L, Unused_Formal) = Initializer_Message (Text, R, Unused_Formal)
   is
      Prefix : constant String :=
        (if Unused_Formal then Unused_Formal_Prefix else Initialization_Prefix);
      Suffix : constant String :=
        (if Unused_Formal then Unused_Formal_Suffix else Initialization_Suffix);
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Byte_Correspondence (Raw, L, Text, R);
         if (R.Last - R.First) + 1 > Prefix'Length + Suffix'Length then
            Literal_Window_Congruence
              (Raw, L.First, Text (R.First .. (R.First + Prefix'Length) - 1), Prefix);
            Literal_Window_Congruence
              (Raw, L.Last - SPARK.Big_Integers.To_Big_Integer (Suffix'Length) + 1,
               Text ((R.Last - Suffix'Length) + 1 .. R.Last), Suffix);
         end if;
      end if;
   end Mixed_Initializer_Message;

   procedure Mixed_Test_Congruence
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Positive_Number (Raw, L) = Positive_Number (Text, R)
         and then Raw_Nonempty_String (Raw, L) = Nonempty_String (Text, R)
         and then Raw_Initializer_Message (Raw, L) = Initializer_Message (Text, R)
         and then Raw_Initializer_Message (Raw, L, True) = Initializer_Message (Text, R, True)
         and then Raw_Output_Message (Raw, L) = Output_Message (Text, R)
   is
   begin
      Mixed_Basic_Tests (Raw, L, Text, R);
      Mixed_Initializer_Message (Raw, L, Text, R);
      Mixed_Initializer_Message (Raw, L, Text, R, True);
      Mixed_Output_Message (Raw, L, Text, R);
   end Mixed_Test_Congruence;

   package Projection_Observations renames Silver_Report_Projection_Observations;
   type Field_Projection_Kind is (Preserved_Value, Check_List_Value);

   function Raw_Field_Agreement
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span;
      Kind : Field_Projection_Kind := Preserved_Value) return Boolean is
     (if L = Raw_Scan.Missing then R = Raw_Scan.Missing
      elsif L = Raw_Scan.Malformed then R = Raw_Scan.Malformed
      elsif Kind = Preserved_Value then Projection_Observations.Same_Content (Raw, L, Projected, R)
      else Projection_Observations.Check_List (Raw, L, Projected, R))
     with Ghost => Static;

   procedure Raw_Merge_Agreement
     (Raw : Raw_Bytes.Sequence; L1, L2 : Raw_Scan.Span;
      Projected : Raw_Bytes.Sequence; R1, R2 : Raw_Scan.Span; Kind : Field_Projection_Kind)
     with Ghost => Static, Global => null,
       Pre => Raw_Field_Agreement (Raw, L1, Projected, R1, Kind)
         and then Raw_Field_Agreement (Raw, L2, Projected, R2, Kind),
       Post => Raw_Field_Agreement
         (Raw, Raw_Merge_Field (L1, L2), Projected, Raw_Merge_Field (R1, R2), Kind)
   is
   begin
      null;
   end Raw_Merge_Agreement;

   --  An observation of one named lookup, before duplicate-sensitive merging.
   --  The result policy is not part of this member relation.
   function Field_Query_Observations
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; RP : Raw_Scan.Offset;
      Name : String; Kind : Field_Projection_Kind) return Boolean
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, L) and then Raw_Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Raw_Bytes.Length (Projected) + 1,
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP);

   function Field_Query_Observations
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; RP : Raw_Scan.Offset;
      Name : String; Kind : Field_Projection_Kind) return Boolean is
     (declare LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
              RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, RP);
      begin LM.State = RM.State and then
        (case LM.State is
           when Raw_Scan.Broken | Raw_Scan.Finished => True,
           when Raw_Scan.Present =>
             Raw_String_Equal (Raw, LM.Key, Name) = Raw_String_Equal (Projected, RM.Key, Name)
             and then (if Raw_String_Equal (Raw, LM.Key, Name) then
               Raw_Field_Agreement (Raw, LM.Value, Projected, RM.Value, Kind))
             and then Field_Query_Observations
               (Raw, L, LM.Next, Projected, R, RM.Next, Name, Kind)));

   procedure Field_Query_Congruence
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; RP : Raw_Scan.Offset;
      Name : String; Kind : Field_Projection_Kind)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, L) and then Raw_Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Raw_Bytes.Length (Projected) + 1
         and then Field_Query_Observations (Raw, L, LP, Projected, R, RP, Name, Kind),
       Post => Raw_Field_Agreement
         (Raw, Raw_Field_From (Raw, L, Name, LP),
          Projected, Raw_Field_From (Projected, R, Name, RP), Kind),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, RP);
   begin
      if LM.State = Raw_Scan.Present then
         Field_Query_Congruence (Raw, L, LM.Next, Projected, R, RM.Next, Name, Kind);
         Raw_Merge_Agreement
           (Raw, (if Raw_String_Equal (Raw, LM.Key, Name) then LM.Value else Raw_Scan.Missing),
            Raw_Field_From (Raw, L, Name, LM.Next),
            Projected, (if Raw_String_Equal (Projected, RM.Key, Name) then RM.Value else Raw_Scan.Missing),
            Raw_Field_From (Projected, R, Name, RM.Next), Kind);
      end if;
   end Field_Query_Congruence;

   procedure Raw_Word_Congruence
     (Raw : Raw_Bytes.Sequence; Item : Raw_Scan.Span; Expected : String)
     with Ghost => Static, Global => null,
       Post => Raw_String_Equal (Raw, Item, Expected) =
         Projection_Observations.Word (Raw, Item, Expected)
   is
   begin
      null;
   end Raw_Word_Congruence;

   procedure Raw_Expected_Congruence
     (Raw : Raw_Bytes.Sequence; Item : Raw_Scan.Span; Left, Right : String)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => Raw_String_Equal (Raw, Item, Left) = Raw_String_Equal (Raw, Item, Right)
   is
   begin
      null;
   end Raw_Expected_Congruence;

   procedure Raw_Content_String_Congruence
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; Expected : String)
     with Ghost => Static, Global => null,
       Pre => Projection_Observations.Same_Content (Raw, L, Projected, R),
       Post => Raw_String_Equal (Raw, L, Expected) = Raw_String_Equal (Projected, R, Expected)
   is
   begin
      pragma Assert (Raw_Bytes.Get (Raw, L.First) = Raw_Bytes.Get (Projected, R.First));
      pragma Assert (Raw_Bytes.Get (Raw, L.Last) = Raw_Bytes.Get (Projected, R.Last));
      if L.Last - L.First = SPARK.Big_Integers.To_Big_Integer (Expected'Length) + 1 then
         pragma Assert (for all I in Expected'Range =>
           Raw_Bytes.Get (Raw, L.First + 1 + SPARK.Big_Integers.To_Big_Integer (I - Expected'First)) =
             Raw_Bytes.Get (Projected, R.First + 1 + SPARK.Big_Integers.To_Big_Integer (I - Expected'First)));
      end if;
   end Raw_Content_String_Congruence;

   procedure Raw_Name_Unique
     (Raw : Raw_Bytes.Sequence; Item : Raw_Scan.Span; First, Second : String)
     with Ghost => Static, Global => null,
       Pre => Raw_String_Equal (Raw, Item, First) and then Raw_String_Equal (Raw, Item, Second),
       Post => First = Second
   is
   begin
      pragma Assert (First'Length = Second'Length);
      for I in 1 .. First'Length loop
         pragma Assert (First (First'First + (I - 1)) = Raw_Bytes.Get (Raw, Item.First + SPARK.Big_Integers.To_Big_Integer (I)));
         pragma Assert (Second (Second'First + (I - 1)) = Raw_Bytes.Get (Raw, Item.First + SPARK.Big_Integers.To_Big_Integer (I)));
         pragma Loop_Invariant (for all J in 1 .. I =>
           First (First'First + (J - 1)) = Second (Second'First + (J - 1)));
      end loop;
   end Raw_Name_Unique;

   procedure Record_Field_Queries
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; RP : Raw_Scan.Offset; Name : String)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, L) and then Raw_Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Raw_Bytes.Length (Projected) + 1
         and then Name /= Projection_Observations.Tree_Name
         and then Projection_Observations.Record_Members (Raw, L, LP, Projected, R, RP),
       Post => Field_Query_Observations (Raw, L, LP, Projected, R, RP, Name, Preserved_Value),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, RP);
   begin
      if LM.State = Raw_Scan.Present then
         Record_Field_Queries (Raw, L, LM.Next, Projected, R, RM.Next, Name);
         Raw_Content_String_Congruence (Raw, LM.Key, Projected, RM.Key, Name);
         if Raw_String_Equal (Raw, LM.Key, Name) then
            Raw_Word_Congruence (Raw, LM.Key, Projection_Observations.Tree_Name);
            if Projection_Observations.Word (Raw, LM.Key, Projection_Observations.Tree_Name) then
               Raw_Name_Unique (Raw, LM.Key, Name, Projection_Observations.Tree_Name);
            end if;
         end if;
      end if;
   end Record_Field_Queries;

   procedure Root_Field_Queries
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; RP : Raw_Scan.Offset;
      Name : String; Kind : Field_Projection_Kind)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, L) and then Raw_Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Raw_Bytes.Length (Projected) + 1
         and then Kind = (if Name = Projection_Observations.Flow_Name
           or else Name = Projection_Observations.Proof_Name then Check_List_Value else Preserved_Value)
         and then Projection_Observations.Root_Members (Raw, L, LP, Projected, R, RP),
       Post => Field_Query_Observations (Raw, L, LP, Projected, R, RP, Name, Kind),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, RP);
   begin
      if LM.State = Raw_Scan.Present then
         Root_Field_Queries (Raw, L, LM.Next, Projected, R, RM.Next, Name, Kind);
         Raw_Content_String_Congruence (Raw, LM.Key, Projected, RM.Key, Name);
         if Raw_String_Equal (Raw, LM.Key, Name) then
            Raw_Word_Congruence (Raw, LM.Key, Projection_Observations.Flow_Name);
            Raw_Word_Congruence (Raw, LM.Key, Projection_Observations.Proof_Name);
            if Kind = Preserved_Value then
               if Projection_Observations.Word (Raw, LM.Key, Projection_Observations.Flow_Name) then
                  Raw_Name_Unique (Raw, LM.Key, Name, Projection_Observations.Flow_Name);
               end if;
               if Projection_Observations.Word (Raw, LM.Key, Projection_Observations.Proof_Name) then
                  Raw_Name_Unique (Raw, LM.Key, Name, Projection_Observations.Proof_Name);
               end if;
            elsif Name = Projection_Observations.Flow_Name then
               Raw_Expected_Congruence (Raw, LM.Key, Name, Projection_Observations.Flow_Name);
            else
               Raw_Expected_Congruence (Raw, LM.Key, Name, Projection_Observations.Proof_Name);
            end if;
         end if;
      end if;
   end Root_Field_Queries;

   package Windows renames Silver_Report_Observation_Windows;

   procedure Content_Window
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span)
     with Ghost => Static, Global => null,
       Pre => Projection_Observations.Same_Content (Raw, L, Projected, R),
       Post => Windows.Same_Window (Raw, Projected, L.First, L.Last, R.First - L.First)
   is
   begin
      pragma Assert (for all I in Projected =>
        (if I >= R.First and then I <= R.Last then
          I - R.First + L.First >= L.First and then I - R.First + L.First <= L.Last
          and then Raw_Bytes.Get (Raw, I - R.First + L.First) = Raw_Bytes.Get (Projected, I)));
   end Content_Window;

   procedure Member_Inside
     (Raw : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Position : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, Object)
         and then Position >= Object.First + 1 and then Position <= Raw_Bytes.Length (Raw) + 1,
       Post => (if Raw_Scan.Member_Spec (Raw, Object, Position).State = Raw_Scan.Present then
         Raw_Scan.Member_Spec (Raw, Object, Position).Key.First >= Position
         and then Raw_Scan.Member_Spec (Raw, Object, Position).Key.Last < Object.Last
         and then Raw_Scan.Member_Spec (Raw, Object, Position).Value.First >= Position
         and then Raw_Scan.Member_Spec (Raw, Object, Position).Value.Last < Object.Last)
   is
   begin
      null;
   end Member_Inside;

   procedure Window_Part
     (Raw : Raw_Bytes.Sequence; L, Part : Raw_Scan.Span;
      Projected : Raw_Bytes.Sequence; R, Other : Raw_Scan.Span)
     with Ghost => Static, Global => null,
       Pre => Projection_Observations.Same_Content (Raw, L, Projected, R)
         and then Raw_Scan.Valid (Raw, Part) and then Part.First >= L.First and then Part.Last <= L.Last
         and then Windows.Shifted_Span (Part, Other, R.First - L.First),
       Post => Projection_Observations.Same_Content (Raw, Part, Projected, Other)
   is
   begin
      null;
   end Window_Part;

   procedure Window_Field_Queries
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Projection_Observations.Same_Content (Raw, L, Projected, R)
         and then LP >= L.First + 1 and then LP <= L.Last + 1,
       Post => Field_Query_Observations
         (Raw, L, LP, Projected, R, R.First + LP - L.First, Name, Preserved_Value),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, R.First + LP - L.First);
   begin
      Content_Window (Raw, L, Projected, R);
      Windows.Member_Window (Raw, Projected, L.First, L.Last, LP, R.First - L.First);
      if LM.State = Raw_Scan.Present then
         Member_Inside (Raw, L, LP);
         Window_Part (Raw, L, LM.Key, Projected, R, RM.Key);
         Window_Part (Raw, L, LM.Value, Projected, R, RM.Value);
         Raw_Content_String_Congruence (Raw, LM.Key, Projected, RM.Key, Name);
         Window_Field_Queries (Raw, L, LM.Next, Projected, R, Name);
      end if;
   end Window_Field_Queries;

   procedure Identity_Field (Text : String; Item : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then (Item = Missing or else Item = Malformed or else Valid (Text, Item)),
       Post => Mixed_Field (Raw_Scan.From_String (Text), Observation_Span (Item), Text, Item)
   is
   begin
      null;
   end Identity_Field;

   procedure Bounded_Merge (Left, Right : Span)
     with Ghost => Static, Global => null,
       Post => Raw_Merge_Field (Observation_Span (Left), Observation_Span (Right)) =
         Observation_Span (Merge_Field (Left, Right))
   is
   begin
      null;
   end Bounded_Merge;

   procedure Bounded_Field_From (Text : String; Object : Span; Name : String; Position : Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Valid (Text, Object) and then Position in Object.First + 1 .. Text'Length + 1,
       Post => Raw_Field_From
         (Raw_Scan.From_String (Text), Observation_Span (Object), Name, To_Big_Integer (Position)) =
           Observation_Span (Field_From (Text, Object, Name, Position)),
       Subprogram_Variant => (Decreases => (Text'Length + 1) - Position)
   is
      M : constant Member := Member_Spec (Text, Object, Position);
   begin
      Member_Observation (Text, Object, Position);
      if M.State = Present then
         Identity_Field (Text, M.Key);
         Mixed_String_Congruence
           (Raw_Scan.From_String (Text), Observation_Span (M.Key), Text, M.Key, Name);
         Bounded_Field_From (Text, Object, Name, M.Next);
         Bounded_Merge ((if String_Equal (Text, M.Key, Name) then M.Value else Missing),
                        Field_From (Text, Object, Name, M.Next));
      end if;
   end Bounded_Field_From;

   procedure Bounded_Field (Text : String; Object : Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
       Post => Raw_Field (Raw_Scan.From_String (Text), Observation_Span (Object), Name) =
         Observation_Span (Field_Spec (Text, Object, Name))
   is
   begin
      if Valid (Text, Object) and then Text (Object.First) = '{' and then Text (Object.Last) = '}' then
         Bounded_Field_From (Text, Object, Name, Object.First + 1);
      end if;
   end Bounded_Field;

   procedure Content_Bounded
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Projection_Observations.Same_Content
           (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R)),
       Post => Mixed_Content (Raw, L, Text, R)
   is
   begin
      pragma Assert (for all I in R.First .. R.Last =>
        Raw_Bytes.Get (Raw, L.First + To_Big_Integer (I - R.First)) = Text (I));
   end Content_Bounded;

   procedure Mixed_To_Content
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R),
       Post => Projection_Observations.Same_Content
         (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R))
   is
   begin
      Mixed_Byte_Correspondence (Raw, L, Text, R);
   end Mixed_To_Content;

   procedure Field_Bounded
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Raw_Field_Agreement
           (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R)),
       Post => Mixed_Field (Raw, L, Text, R)
   is
   begin
      if L /= Raw_Scan.Missing and then L /= Raw_Scan.Malformed then
         Content_Bounded (Raw, L, Text, R);
      end if;
   end Field_Bounded;

   procedure Mixed_Preserved_Field
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Mixed_Field
         (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name))
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_To_Content (Raw, L, Text, R);
         if Raw_Bytes.Get (Raw, L.First) = '{' and then Raw_Bytes.Get (Raw, L.Last) = '}' then
            Window_Field_Queries (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R), Name);
            Field_Query_Congruence
              (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
               To_Big_Integer (R.First) + 1, Name, Preserved_Value);
            Bounded_Field (Text, R, Name);
            Field_Bounded (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name));
         end if;
      end if;
   end Mixed_Preserved_Field;

   procedure Mixed_Record_Field
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Name /= Projection_Observations.Tree_Name
         and then Projection_Observations.Check_Record
           (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R)),
       Post => Mixed_Field (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name))
   is
   begin
      Record_Field_Queries
        (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R), To_Big_Integer (R.First) + 1, Name);
      Field_Query_Congruence
        (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
         To_Big_Integer (R.First) + 1, Name, Preserved_Value);
      Bounded_Field (Text, R, Name);
      Field_Bounded (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name));
   end Mixed_Record_Field;

   procedure Raw_Dynamic_Key
     (Raw : Raw_Bytes.Sequence; Key, Name : Raw_Scan.Span; Expected : String)
     with Ghost => Static, Global => null,
       Pre => Raw_Name_Range (Raw, Name)
         and then Name.Last + 1 - Name.First = To_Big_Integer (Expected'Length)
         and then Raw_Scan.Window_Matches (Raw, Name.First, Expected),
       Post => Raw_Key_Equal (Raw, Key, Name, False) = Raw_String_Equal (Raw, Key, Expected)
   is
   begin
      if Raw_Scan.Valid (Raw, Key) and then Key.Last - Key.First = To_Big_Integer (Expected'Length) + 1 then
         pragma Assert (for all I in Expected'Range =>
           Raw_Bytes.Get (Raw, Name.First + To_Big_Integer (I - Expected'First)) = Expected (I));
         pragma Assert (for all I in Raw =>
           (if I >= Name.First and then I <= Name.Last then
             I - Name.First < To_Big_Integer (Expected'Length)
             and then Raw_Bytes.Get (Raw, I) = Expected (Expected'First + To_Integer (I - Name.First))));
      end if;
   end Raw_Dynamic_Key;

   procedure Raw_Padded_Dynamic_Key
     (Raw : Raw_Bytes.Sequence; Key, Name : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, Name, Text, R),
       Post => Raw_Key_Equal (Raw, Key, Name, True) = Raw_String_Equal (Raw, Key, Padded_Key (Text, R))
   is
      Expected : constant String := Padded_Key (Text, R);
   begin
      Mixed_Byte_Correspondence (Raw, Name, Text, R);
      if Raw_Scan.Valid (Raw, Key) and then Key.Last - Key.First = To_Big_Integer (Expected'Length) + 1 then
         pragma Assert (for all I in R.First .. R.Last =>
           Expected (2 + (I - R.First)) = Raw_Bytes.Get (Raw, Name.First + To_Big_Integer (I - R.First)));
         pragma Assert (for all I in Raw =>
           (if I >= Name.First and then I <= Name.Last then
             Raw_Bytes.Get (Raw, I) = Expected (2 + To_Integer (I - Name.First))));
      end if;
   end Raw_Padded_Dynamic_Key;

   procedure Raw_Dynamic_Field_From
     (Raw : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span; Expected : String;
      Position : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, Object) and then Raw_Name_Range (Raw, Name)
         and then Name.Last + 1 - Name.First = To_Big_Integer (Expected'Length)
         and then Raw_Scan.Window_Matches (Raw, Name.First, Expected)
         and then Position >= Object.First + 1 and then Position <= Raw_Bytes.Length (Raw) + 1,
       Post => Raw_Field_Key_From (Raw, Object, Name, False, Position) =
         Raw_Field_From (Raw, Object, Expected, Position),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - Position)
   is
      M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, Object, Position);
   begin
      if M.State = Raw_Scan.Present then
         Raw_Dynamic_Key (Raw, M.Key, Name, Expected);
         Raw_Dynamic_Field_From (Raw, Object, Name, Expected, M.Next);
      end if;
   end Raw_Dynamic_Field_From;

   procedure Raw_Dynamic_Field
     (Raw : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span; Expected : String)
     with Ghost => Static, Global => null,
       Pre => Raw_Name_Range (Raw, Name)
         and then Name.Last + 1 - Name.First = To_Big_Integer (Expected'Length)
         and then Raw_Scan.Window_Matches (Raw, Name.First, Expected),
       Post => Raw_Field_Key (Raw, Object, Name) = Raw_Field (Raw, Object, Expected)
   is
   begin
      if Raw_Scan.Valid (Raw, Object) and then Raw_Bytes.Get (Raw, Object.First) = '{'
        and then Raw_Bytes.Get (Raw, Object.Last) = '}'
      then
         Raw_Dynamic_Field_From (Raw, Object, Name, Expected, Object.First + 1);
      end if;
   end Raw_Dynamic_Field;

   procedure Raw_Padded_Field_From
     (Raw : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span; Text : String; R : Span;
      Position : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, Name, Text, R)
         and then Raw_Scan.Valid (Raw, Object)
         and then Position >= Object.First + 1 and then Position <= Raw_Bytes.Length (Raw) + 1,
       Post => Raw_Field_Key_From (Raw, Object, Name, True, Position) =
         Raw_Field_From (Raw, Object, Padded_Key (Text, R), Position),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - Position)
   is
      M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, Object, Position);
   begin
      if M.State = Raw_Scan.Present then
         Raw_Padded_Dynamic_Key (Raw, M.Key, Name, Text, R);
         Raw_Padded_Field_From (Raw, Object, Name, Text, R, M.Next);
      end if;
   end Raw_Padded_Field_From;

   procedure Raw_Padded_Field
     (Raw : Raw_Bytes.Sequence; Object, Name : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, Name, Text, R),
       Post => Raw_Field_Key (Raw, Object, Name, True) = Raw_Field (Raw, Object, Padded_Key (Text, R))
   is
   begin
      if Raw_Scan.Valid (Raw, Object) and then Raw_Bytes.Get (Raw, Object.First) = '{'
        and then Raw_Bytes.Get (Raw, Object.Last) = '}'
      then
         Raw_Padded_Field_From (Raw, Object, Name, Text, R, Object.First + 1);
      end if;
   end Raw_Padded_Field;

   procedure Mixed_Referenced_Entity
     (Raw : Raw_Bytes.Sequence; Entities, Arg : Raw_Scan.Span; Text : String; RE, RA : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, Entities, Text, RE) and then Mixed_Field (Raw, Arg, Text, RA),
       Post => Mixed_Field
         (Raw, Raw_Referenced_Entity (Raw, Entities, Arg), Text, Referenced_Entity_Spec (Text, RE, RA))
   is
   begin
      if Mixed_Content (Raw, Arg, Text, RA) then
         Mixed_Byte_Correspondence (Raw, Arg, Text, RA);
         if (for all I in RA.First .. RA.Last => Text (I) in '0' .. '9') then
            Raw_Padded_Field (Raw, Entities, Arg, Text, RA);
            Mixed_Preserved_Field (Raw, Entities, Text, RE, Padded_Key (Text, RA));
            Raw_Dynamic_Field (Raw, Entities, Arg, Text (RA.First .. RA.Last));
            Mixed_Preserved_Field (Raw, Entities, Text, RE, Text (RA.First .. RA.Last));
         end if;
      end if;
   end Mixed_Referenced_Entity;

   procedure Space_Before
     (Raw : Raw_Bytes.Sequence; Position, Stop : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Position >= 1 and then Position <= Stop and then Stop <= Raw_Bytes.Length (Raw)
         and then not Raw_Scan.Space (Raw_Bytes.Get (Raw, Stop)),
       Post => Raw_Scan.Space_End (Raw, Position) <= Stop,
       Subprogram_Variant => (Decreases => Stop + 1 - Position)
   is
   begin
      if Raw_Scan.Space (Raw_Bytes.Get (Raw, Position)) then
         Space_Before (Raw, Position + 1, Stop);
      end if;
   end Space_Before;

   procedure Mixed_Location
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Name : Entity_Kind)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Location (Raw, L, Name) = Location_Policy (Text, R, Name)
   is
      LL : constant Raw_Scan.Span := Raw_Field (Raw, L, JSON_sloc);
      RR : constant Span := Field_Spec (Text, R, JSON_sloc);
      LP, LE : Raw_Scan.Offset := 0;
      RP, RE : Offset := 0;
      Projected : constant Raw_Bytes.Sequence := Raw_Scan.From_String (Text);
   begin
      if Name = Unknown then
         pragma Assert (not Raw_Location (Raw, L, Name));
         pragma Assert (not Location_Policy (Text, R, Name));
         return;
      end if;
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_sloc);
      pragma Assert (Raw_Scan.Valid (Raw, LL) = Valid (Text, RR));
      if not Raw_Scan.Valid (Raw, LL) then
         pragma Assert (not Raw_Location (Raw, L, Name));
         pragma Assert (not Location_Policy (Text, R, Name));
         return;
      end if;
      pragma Assert (Mixed_Content (Raw, LL, Text, RR));
      pragma Assert (Raw_Bytes.Get (Raw, LL.First) = Text (RR.First));
      pragma Assert (Raw_Bytes.Get (Raw, LL.Last) = Text (RR.Last));
      Mixed_To_Content (Raw, LL, Text, RR);
      if Raw_Bytes.Get (Raw, LL.First) /= '[' or else Raw_Bytes.Get (Raw, LL.Last) /= ']' then
         pragma Assert (not Raw_Location (Raw, L, Name));
         pragma Assert (not Location_Policy (Text, R, Name));
         return;
      end if;
      Content_Window (Raw, LL, Projected, Observation_Span (RR));
      Space_Before (Raw, LL.First + 1, LL.Last);
      Windows.Space_End_Window (Raw, Projected, LL.First, LL.Last, LL.First + 1,
                                To_Big_Integer (RR.First) - LL.First);
      Space_End_Observation (Text, RR.First + 1);
      LP := Raw_Scan.Space_End (Raw, LL.First + 1);
      RP := Space_End (Text, RR.First + 1);
      Windows.Value_Spec_Equivalent (Raw, Projected, LL.First, LL.Last, LP,
                                     To_Big_Integer (RR.First) - LL.First);
      Value_Spec_Observation (Text, RP);
      LE := Raw_Scan.Value_Spec (Raw, LP);
      RE := Value_Spec (Text, RP);
      pragma Assert ((LE /= 0 and then LE < LL.Last) = (RE /= 0 and then RE < RR.Last));
      if LE = 0 or else LE >= LL.Last then
         pragma Assert (not Raw_Location (Raw, L, Name));
         pragma Assert (not Location_Policy (Text, R, Name));
         return;
      end if;
      Windows.Space_End_Equivalent (Raw, Projected, LL.First, LL.Last, LE + 1,
                                    To_Big_Integer (RR.First) - LL.First);
      Space_End_Observation (Text, RE + 1);
      pragma Assert ((Raw_Scan.Space_End (Raw, LE + 1) = LL.Last) =
                       (Space_End (Text, RE + 1) = RR.Last));
      if Raw_Scan.Space_End (Raw, LE + 1) /= LL.Last then
         pragma Assert (not Raw_Location (Raw, L, Name));
         pragma Assert (not Location_Policy (Text, R, Name));
         return;
      end if;
      Window_Part (Raw, LL, (LP, LE), Projected, Observation_Span (RR), Observation_Span ((RP, RE)));
      Content_Bounded (Raw, (LP, LE), Text, (RP, RE));
      Mixed_Preserved_Field (Raw, (LP, LE), Text, (RP, RE), JSON_file);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, (LP, LE), JSON_file), Text,
         Field_Spec (Text, (RP, RE), JSON_file), Entity_File (Name));
      pragma Assert (Raw_Location (Raw, L, Name) =
        Raw_String_Equal (Raw, Raw_Field (Raw, (LP, LE), JSON_file), Entity_File (Name)));
      pragma Assert (Location_Policy (Text, R, Name) =
        String_Equal (Text, Field_Spec (Text, (RP, RE), JSON_file), Entity_File (Name)));
   end Mixed_Location;

   procedure Mixed_Main_Spelling
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Main_Spelling (Raw, L) = Main_Spelling (Text, R)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Byte_Correspondence (Raw, L, Text, R);
      end if;
   end Mixed_Main_Spelling;

   procedure Mixed_Function_Name
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span;
      Source : String; Functions : Function_Metadata; Count : Function_Bindings.Function_Count)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Count <= Functions.Count,
       Post => Raw_Function_Name (Raw, L, Source, Functions, Count) =
         Function_Name_Model (Text, R, Source, Functions, Count),
       Subprogram_Variant => (Decreases => Count)
   is
   begin
      if Count = 0 then return; end if;
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Byte_Correspondence (Raw, L, Text, R);
      end if;
      pragma Assert (Raw_Function_Spelling (Raw, L, Source, Functions.Items (Count)) =
        Function_Spelling (Text, R, Source, Functions.Items (Count)));
      Mixed_Function_Name (Raw, L, Text, R, Source, Functions, Count - 1);
   end Mixed_Function_Name;

   procedure Mixed_Procedure_Name
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span;
      Source : String; Procedures : Procedure_Metadata; Count : Procedure_Bindings.Procedure_Count)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Count <= Procedures.Count,
       Post => Raw_Procedure_Name (Raw, L, Source, Procedures, Count) =
         Procedure_Name_Model (Text, R, Source, Procedures, Count),
       Subprogram_Variant => (Decreases => Count)
   is
   begin
      if Count = 0 then return; end if;
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Byte_Correspondence (Raw, L, Text, R);
      end if;
      pragma Assert (Raw_Procedure_Spelling (Raw, L, Source, Procedures.Items (Count)) =
        Procedure_Spelling (Text, R, Source, Procedures.Items (Count)));
      Mixed_Procedure_Name (Raw, L, Text, R, Source, Procedures, Count - 1);
   end Mixed_Procedure_Name;

   procedure Mixed_Entity_Name
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Entity_Name (Raw, L, Source => Source, Functions => Functions, Procedures => Procedures) = Entity_Name_Spec (Text, R, Source => Source, Functions => Functions, Procedures => Procedures)
   is
      Name : constant Raw_Scan.Span := Raw_Field (Raw, L, JSON_name);
      Other : constant Span := Field_Spec (Text, R, JSON_name);
              Kind : constant Entity_Kind := (
          if Raw_Main_Spelling (Raw, Name) then Main_Entity
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_IO) then IO_Package
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_IO_Put_Line) then Put_Line
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_IO_Put) then Put
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Output_Libc) then Libc_Package
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Output_Libc_Put_Byte) then Put_Byte
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Output_Libc_Flush) then Flush
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Output_Libc_Set_Exit_Status) then Set_Exit_Status
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Arguments) then Arguments_Package
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Arguments_Input_Is_Valid) then Input_Is_Valid
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Arguments_First_Or_Default) then First_Or_Default
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Arguments_Reject) then Reject
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Arguments_Is_Message) then Is_Message
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Runtime) then Runtime_Package
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Runtime_Argument_Count) then Argument_Count
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Runtime_Argument) then Argument
          elsif Raw_String_Equal (Raw, Name, Atom_Silver_Runtime_Set_Exit_Status) then Runtime_Exit_Status
          else (if Raw_Function_Name (Raw, Name, Source, Functions, Functions.Count) /= Unknown then Raw_Function_Name (Raw, Name, Source, Functions, Functions.Count)
           else Raw_Procedure_Name (Raw, Name, Source, Procedures, Procedures.Count)));
   begin
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_name);
      Mixed_Main_Spelling (Raw, Name, Text, Other);
      Mixed_Function_Name (Raw, Name, Text, Other, Source, Functions, Functions.Count);
      Mixed_Procedure_Name (Raw, Name, Text, Other, Source, Procedures, Procedures.Count);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_IO);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_IO_Put_Line);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_IO_Put);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Output_Libc);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Output_Libc_Put_Byte);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Output_Libc_Flush);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Output_Libc_Set_Exit_Status);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Arguments);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Arguments_Input_Is_Valid);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Arguments_First_Or_Default);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Arguments_Reject);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Arguments_Is_Message);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Runtime);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Runtime_Argument_Count);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Runtime_Argument);
      Mixed_String_Congruence (Raw, Name, Text, Other, Atom_Silver_Runtime_Set_Exit_Status);
      Mixed_Location (Raw, L, Text, R, Kind);
   end Mixed_Entity_Name;

   procedure Raw_Field_Inside
     (Raw : Raw_Bytes.Sequence; Object : Raw_Scan.Span; Name : String; Position : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, Object)
         and then Position >= Object.First + 1 and then Position <= Raw_Bytes.Length (Raw) + 1,
       Post => (if Raw_Field_From (Raw, Object, Name, Position).First /= 0 then
         Raw_Field_From (Raw, Object, Name, Position).First >= Position
         and then Raw_Field_From (Raw, Object, Name, Position).Last < Object.Last),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - Position)
   is
      M : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, Object, Position);
   begin
      if M.State = Raw_Scan.Present then
         Member_Inside (Raw, Object, Position);
         Raw_Field_Inside (Raw, Object, Name, M.Next);
      end if;
   end Raw_Field_Inside;

   procedure Shifted_Merge
     (Left_One, Left_Two, Right_One, Right_Two : Raw_Scan.Span; Shift : Big_Integer)
     with Ghost => Static, Global => null,
       Pre => Windows.Shifted_Span (Left_One, Right_One, Shift)
         and then Windows.Shifted_Span (Left_Two, Right_Two, Shift)
         and then (if Left_One.First /= 0 then Right_One.First >= 1)
         and then (if Left_Two.First /= 0 then Right_Two.First >= 1),
       Post => Windows.Shifted_Span
         (Raw_Merge_Field (Left_One, Left_Two), Raw_Merge_Field (Right_One, Right_Two), Shift)
   is
   begin
      null;
   end Shifted_Merge;

   procedure Window_Field_Shift
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Projected : Raw_Bytes.Sequence; R : Raw_Scan.Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Projection_Observations.Same_Content (Raw, L, Projected, R)
         and then LP >= L.First + 1 and then LP <= L.Last + 1,
       Post => Windows.Shifted_Span
         (Raw_Field_From (Raw, L, Name, LP),
          Raw_Field_From (Projected, R, Name, R.First + LP - L.First), R.First - L.First),
       Subprogram_Variant => (Decreases => Raw_Bytes.Length (Raw) + 1 - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Projected, R, R.First + LP - L.First);
   begin
      Content_Window (Raw, L, Projected, R);
      Windows.Member_Window (Raw, Projected, L.First, L.Last, LP, R.First - L.First);
      if LM.State = Raw_Scan.Present then
         Member_Inside (Raw, L, LP);
         Window_Part (Raw, L, LM.Key, Projected, R, RM.Key);
         Raw_Content_String_Congruence (Raw, LM.Key, Projected, RM.Key, Name);
         Window_Field_Shift (Raw, L, LM.Next, Projected, R, Name);
         Raw_Field_Inside (Raw, L, Name, LM.Next);
         Shifted_Merge
           ((if Raw_String_Equal (Raw, LM.Key, Name) then LM.Value else Raw_Scan.Missing),
            Raw_Field_From (Raw, L, Name, LM.Next),
            (if Raw_String_Equal (Projected, RM.Key, Name) then RM.Value else Raw_Scan.Missing),
            Raw_Field_From (Projected, R, Name, RM.Next), R.First - L.First);
      end if;
   end Window_Field_Shift;

   procedure Mixed_Field_Shift
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R),
       Post => Windows.Shifted_Span
         (Raw_Field (Raw, L, Name), Observation_Span (Field_Spec (Text, R, Name)),
          To_Big_Integer (R.First) - L.First)
   is
   begin
      Mixed_To_Content (Raw, L, Text, R);
      if Raw_Bytes.Get (Raw, L.First) = '{' and then Raw_Bytes.Get (Raw, L.Last) = '}' then
         Window_Field_Shift (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R), Name);
         Bounded_Field (Text, R, Name);
      end if;
   end Mixed_Field_Shift;

   --  This relation records byte observations and resolved entity identity.
   --  It contains no policy acceptance result.
   function Record_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Record_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_severity),
         Text, Field_Spec (Text, R, JSON_severity))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_how_proved),
         Text, Field_Spec (Text, R, JSON_how_proved))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_line),
         Text, Field_Spec (Text, R, JSON_line))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_col),
         Text, Field_Spec (Text, R, JSON_col))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_entity),
         Text, Field_Spec (Text, R, JSON_entity))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_justification),
         Text, Field_Spec (Text, R, JSON_justification))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_justified),
         Text, Field_Spec (Text, R, JSON_justified))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_suppressed),
         Text, Field_Spec (Text, R, JSON_suppressed))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_annot_kind),
         Text, Field_Spec (Text, R, JSON_annot_kind))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_justif_msg),
         Text, Field_Spec (Text, R, JSON_justif_msg))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text))
      and then (if For_Image then
        Mixed_Field (Raw, Raw_Field (Raw, L, JSON_check_tree), Text, Field_Spec (Text, R, JSON_check_tree))
        and then Mixed_Field
          (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_unproved_status), JSON_status),
           Text, Field_Spec (Text, Field_Spec (Text, R, JSON_unproved_status), JSON_status)))
      and then Raw_Entity_Name
        (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures) =
          Entity_Name_Spec
            (Text, Referenced_Entity_Spec (Text, RE, Field_Spec (Text, R, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures));

   procedure Mixed_Empty_Object
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Empty_Object (Raw, L) = Empty_Object_Spec (Text, R)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) and then Raw_Bytes.Get (Raw, L.First) = '{'
        and then Raw_Bytes.Get (Raw, L.Last) = '}'
      then
         Mixed_To_Content (Raw, L, Text, R);
         Content_Window (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R));
         Windows.Space_End_Equivalent
           (Raw, Raw_Scan.From_String (Text), L.First, L.Last, L.First + 1, To_Big_Integer (R.First) - L.First);
         Space_End_Observation (Text, R.First + 1);
      end if;
   end Mixed_Empty_Object;

   procedure Mixed_Initialization_Index
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span;
      Source : String; Procedures : Procedure_Metadata;
      Name : Entity_Kind; Count : Procedure_Bindings.Formal_Count)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Count <= Procedures.Parameter_Count,
       Post => Raw_Initialization_Index (Raw, L, Source, Procedures, Name, Count) =
         Initialization_Index_Model (Text, R, Source, Procedures, Name, Count),
       Subprogram_Variant => (Decreases => Count)
   is
   begin
      if Count = 0 then return; end if;
      Mixed_String_Congruence
        (Raw, L, Text, R, Initialization_Message (Source, Procedures.Parameters (Count)));
      Mixed_Initialization_Index (Raw, L, Text, R, Source, Procedures, Name, Count - 1);
   end Mixed_Initialization_Index;

   procedure Mixed_Record_Congruence
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Kind /= References
         and then Record_Observation_Agreement (Raw, L, LE, Text, R, RE, Kind = Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures),
       Post => Raw_Record_Policy (Raw, L, LE, Kind, Source => Source, Functions => Functions, Procedures => Procedures) = Record_Policy (Text, R, RE, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Mixed_Initialization_Index
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text), Source, Procedures,
         Raw_Entity_Name (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_entity)),
           Source => Source, Functions => Functions, Procedures => Procedures), Procedures.Parameter_Count);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_UNINITIALIZED);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_UNUSED_VARIABLE);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_SUBPROGRAM_TERMINATION);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text),
         Termination_Message (Raw_Entity_Name
           (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures), Source => Source, Functions => Functions));
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_severity),
         Text, Field_Spec (Text, R, JSON_severity), Atom_warning);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_severity),
         Text, Field_Spec (Text, R, JSON_severity), Atom_info);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_how_proved),
         Text, Field_Spec (Text, R, JSON_how_proved), JSON_flow);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_how_proved),
         Text, Field_Spec (Text, R, JSON_how_proved), Atom_prover);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_how_proved),
         Text, Field_Spec (Text, R, JSON_how_proved), Atom_trivial);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_main_adb);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_io_ads);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_io_adb);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_output_libc_ads);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_arguments_ads);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_arguments_adb);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_file),
         Text, Field_Spec (Text, R, JSON_file), Atom_silver_runtime_ads);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_INEFFECTIVE);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_DEAD_CODE);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_POSTCONDITION);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_RANGE_CHECK);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_LENGTH_CHECK);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_OVERFLOW_CHECK);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_DIVISION_CHECK);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule), Atom_VC_INDEX_CHECK);
      Mixed_Test_Congruence
        (Raw, Raw_Field (Raw, L, JSON_line),
         Text, Field_Spec (Text, R, JSON_line));
      Mixed_Test_Congruence
        (Raw, Raw_Field (Raw, L, JSON_col),
         Text, Field_Spec (Text, R, JSON_col));
      Mixed_Test_Congruence
        (Raw, Raw_Field (Raw, L, JSON_rule),
         Text, Field_Spec (Text, R, JSON_rule));
      Mixed_Test_Congruence
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text));
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text),
         Atom_unused_assignment);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text),
         Atom_statement_no_effect);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
         Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text),
         Atom_statement_unreachable);
      if Kind = Main_Advisories then
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, L, JSON_rule), Text, Field_Spec (Text, R, JSON_rule), Atom_imprecise_image);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, L, JSON_rule), Text, Field_Spec (Text, R, JSON_rule), Atom_array_initialization);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
            Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text), Atom_array_initialization_message);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, L, JSON_suppressed), Text, Field_Spec (Text, R, JSON_suppressed), Atom_Empty);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
            Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text), Atom_image_message);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
            Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text), Atom_image_message_lower);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_message), JSON_text),
            Text, Field_Spec (Text, Field_Spec (Text, R, JSON_message), JSON_text), Atom_image_message_upper);
         Mixed_String_Congruence
           (Raw, Raw_Field (Raw, Raw_Field (Raw, L, JSON_unproved_status), JSON_status),
            Text, Field_Spec (Text, Field_Spec (Text, R, JSON_unproved_status), JSON_status), Atom_unknown);
         Mixed_Empty_Object
           (Raw, Raw_Field (Raw, L, JSON_check_tree), Text, Field_Spec (Text, R, JSON_check_tree));
      end if;
   end Mixed_Record_Congruence;
   function Reference_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Reference_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_predicate),
         Text, Field_Spec (Text, R, JSON_predicate))
      and then Mixed_Field
        (Raw, Raw_Field (Raw, L, JSON_arg),
         Text, Field_Spec (Text, R, JSON_arg))
      and then Raw_Entity_Name
        (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures) =
          Entity_Name_Spec
            (Text, Referenced_Entity_Spec (Text, RE, Field_Spec (Text, R, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures));

   procedure Mixed_Reference_Congruence
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Reference_Observation_Agreement (Raw, L, LE, Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures),
       Post => Raw_Reference_Policy (Raw, LE, L, Source => Source, Functions => Functions, Procedures => Procedures) = Reference_Policy (Text, RE, R, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_predicate),
         Text, Field_Spec (Text, R, JSON_predicate), Atom_CLAIM_POST);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_predicate),
         Text, Field_Spec (Text, R, JSON_predicate), Atom_CLAIM_AORTE);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_predicate),
         Text, Field_Spec (Text, R, JSON_predicate), Atom_CLAIM_EFFECTS);
   end Mixed_Reference_Congruence;

   function Raw_State (State : Member_State) return Raw_Scan.Member_State is
     (case State is
        when Broken => Raw_Scan.Broken,
        when Finished => Raw_Scan.Finished,
        when Present => Raw_Scan.Present)
     with Ghost => Static;

   --  Item correspondence preserves record order and malformed/finished states.
   --  It is independent of the result of List_Policy or Record_Policy.
   function List_Items_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Raw_Scan.Valid (Raw, L) and then Valid (Text, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP in R.First + 1 .. Text'Length + 1,
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP);

   function List_Items_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (declare LM : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Raw, L, LP);
              RM : constant Member := Item_Spec (Text, R, RP);
      begin
        LM.State = Raw_State (RM.State) and then
          (case LM.State is
             when Raw_Scan.Broken | Raw_Scan.Finished => True,
             when Raw_Scan.Present =>
               (if For_References then
                  Reference_Observation_Agreement (Raw, LM.Value, LE, Text, RM.Value, RE, Source => Source, Functions => Functions, Procedures => Procedures)
                else Record_Observation_Agreement (Raw, LM.Value, LE, Text, RM.Value, RE, For_Image, Source => Source, Functions => Functions, Procedures => Procedures))
               and then List_Items_Agreement
                 (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures)));

   procedure Mixed_List_Items_Congruence
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Raw_Scan.Valid (Raw, L) and then Valid (Text, R)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP in R.First + 1 .. Text'Length + 1
         and then List_Items_Agreement
           (Raw, L, LE, LP, Text, R, RE, RP, Kind = References, Kind = Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures),
       Post => Raw_List_From (Raw, L, LE, Kind, LP, Source => Source, Functions => Functions, Procedures => Procedures) = List_From (Text, R, RE, Kind, RP, Source => Source, Functions => Functions, Procedures => Procedures),
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Raw, L, LP);
      RM : constant Member := Item_Spec (Text, R, RP);
   begin
      if LM.State = Raw_Scan.Present then
         if Kind = References then
            Mixed_Reference_Congruence (Raw, LM.Value, LE, Text, RM.Value, RE, Source => Source, Functions => Functions, Procedures => Procedures);
         else
            Mixed_Record_Congruence (Raw, LM.Value, LE, Text, RM.Value, RE, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
         end if;
         Mixed_List_Items_Congruence
           (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_List_Items_Congruence;

   function List_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function List_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean is
     (Raw_Scan.Valid (Raw, L) = Valid (Text, R)
      and then (if Raw_Scan.Valid (Raw, L) then
        Raw_Bytes.Get (Raw, L.First) = Text (R.First) and then Raw_Bytes.Get (Raw, L.Last) = Text (R.Last)
        and then (if Raw_Bytes.Get (Raw, L.First) = '[' and then Raw_Bytes.Get (Raw, L.Last) = ']' then
          List_Items_Agreement
            (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures))));

   procedure Mixed_List_Congruence
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span; Kind : List_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then List_Observation_Agreement (Raw, L, LE, Text, R, RE, Kind = References, Kind = Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures),
       Post => Raw_List_Spec (Raw, L, LE, Kind, Source => Source, Functions => Functions, Procedures => Procedures) = List_Spec (Text, R, RE, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if Raw_Scan.Valid (Raw, L) and then Raw_Bytes.Get (Raw, L.First) = '[' and then Raw_Bytes.Get (Raw, L.Last) = ']' then
         Mixed_List_Items_Congruence (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_List_Congruence;

   procedure Observe_Check_Record
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, LE, Text, RE)
         and then Projection_Observations.Check_Record
           (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R)),
       Post => Record_Observation_Agreement (Raw, L, LE, Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Mixed_Record_Field (Raw, L, Text, R, JSON_severity);
      Mixed_Record_Field (Raw, L, Text, R, JSON_how_proved);
      Mixed_Record_Field (Raw, L, Text, R, JSON_file);
      Mixed_Record_Field (Raw, L, Text, R, JSON_line);
      Mixed_Record_Field (Raw, L, Text, R, JSON_col);
      Mixed_Record_Field (Raw, L, Text, R, JSON_rule);
      Mixed_Record_Field (Raw, L, Text, R, JSON_entity);
      Mixed_Record_Field (Raw, L, Text, R, JSON_justification);
      Mixed_Record_Field (Raw, L, Text, R, JSON_justified);
      Mixed_Record_Field (Raw, L, Text, R, JSON_suppressed);
      Mixed_Record_Field (Raw, L, Text, R, JSON_annot_kind);
      Mixed_Record_Field (Raw, L, Text, R, JSON_justif_msg);
      Mixed_Record_Field (Raw, L, Text, R, JSON_message);
      Mixed_Preserved_Field
        (Raw, Raw_Field (Raw, L, JSON_message), Text, Field_Spec (Text, R, JSON_message), JSON_text);
      Mixed_Referenced_Entity
        (Raw, LE, Raw_Field (Raw, L, JSON_entity), Text, RE, Field_Spec (Text, R, JSON_entity));
      Mixed_Entity_Name
        (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_entity)),
         Text, Referenced_Entity_Spec (Text, RE, Field_Spec (Text, R, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
   end Observe_Check_Record;

   procedure Observe_Preserved_Record
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, LE, Text, RE)
         and then Mixed_Field (Raw, L, Text, R),
       Post => Record_Observation_Agreement (Raw, L, LE, Text, R, RE, For_Image, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_severity);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_how_proved);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_file);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_line);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_col);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_rule);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_entity);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_justification);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_justified);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_suppressed);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_annot_kind);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_justif_msg);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_message);
      Mixed_Preserved_Field
        (Raw, Raw_Field (Raw, L, JSON_message), Text, Field_Spec (Text, R, JSON_message), JSON_text);
      Mixed_Referenced_Entity
        (Raw, LE, Raw_Field (Raw, L, JSON_entity), Text, RE, Field_Spec (Text, R, JSON_entity));
      Mixed_Entity_Name
        (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_entity)),
         Text, Referenced_Entity_Spec (Text, RE, Field_Spec (Text, R, JSON_entity)), Source => Source, Functions => Functions, Procedures => Procedures);
      if For_Image then
         Mixed_Preserved_Field (Raw, L, Text, R, JSON_check_tree);
         Mixed_Preserved_Field (Raw, L, Text, R, JSON_unproved_status);
         Mixed_Preserved_Field
           (Raw, Raw_Field (Raw, L, JSON_unproved_status), Text, Field_Spec (Text, R, JSON_unproved_status), JSON_status);
      end if;
   end Observe_Preserved_Record;

   procedure Observe_Reference
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, LE, Text, RE) and then Mixed_Field (Raw, L, Text, R),
       Post => Reference_Observation_Agreement (Raw, L, LE, Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_predicate);
      Mixed_Preserved_Field (Raw, L, Text, R, JSON_arg);
      Mixed_Referenced_Entity
        (Raw, LE, Raw_Field (Raw, L, JSON_arg), Text, RE, Field_Spec (Text, R, JSON_arg));
      Mixed_Entity_Name
        (Raw, Raw_Referenced_Entity (Raw, LE, Raw_Field (Raw, L, JSON_arg)),
         Text, Referenced_Entity_Spec (Text, RE, Field_Spec (Text, R, JSON_arg)), Source => Source, Functions => Functions, Procedures => Procedures);
   end Observe_Reference;

   procedure Item_Inside
     (Raw : Raw_Bytes.Sequence; Items : Raw_Scan.Span; Position : Raw_Scan.Offset)
     with Ghost => Static, Global => null,
       Pre => Raw_Scan.Valid (Raw, Items)
         and then Position >= Items.First + 1 and then Position <= Raw_Bytes.Length (Raw) + 1,
       Post => (if Raw_Scan.Item_Spec (Raw, Items, Position).State = Raw_Scan.Present then
         Raw_Scan.Item_Spec (Raw, Items, Position).Value.First >= Position
         and then Raw_Scan.Item_Spec (Raw, Items, Position).Value.Last < Items.Last)
   is
   begin
      null;
   end Item_Inside;

   procedure Observe_Preserved_Items
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE)
         and then RP in R.First + 1 .. R.Last + 1
         and then LP = L.First + To_Big_Integer (RP - R.First),
       Post => List_Items_Agreement (Raw, L, LE, LP, Text, R, RE, RP, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures),
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Raw, L, LP);
      RM : constant Member := Item_Spec (Text, R, RP);
      Projected : constant Raw_Bytes.Sequence := Raw_Scan.From_String (Text);
   begin
      Mixed_To_Content (Raw, L, Text, R);
      Content_Window (Raw, L, Projected, Observation_Span (R));
      Windows.Item_Window (Raw, Projected, L.First, L.Last, LP, To_Big_Integer (R.First) - L.First);
      Item_Observation (Text, R, RP);
      if LM.State = Raw_Scan.Present then
         Item_Inside (Raw, L, LP);
         Window_Part (Raw, L, LM.Value, Projected, Observation_Span (R), Observation_Span (RM.Value));
         Content_Bounded (Raw, LM.Value, Text, RM.Value);
         if For_References then
            Observe_Reference (Raw, LM.Value, LE, Text, RM.Value, RE, Source => Source, Functions => Functions, Procedures => Procedures);
         else
            Observe_Preserved_Record (Raw, LM.Value, LE, Text, RM.Value, RE, For_Image, Source => Source, Functions => Functions, Procedures => Procedures);
         end if;
         Observe_Preserved_Items (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Observe_Preserved_Items;

   procedure Observe_Preserved_List
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      For_References : Boolean; For_Image : Boolean := False;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE),
       Post => List_Observation_Agreement (Raw, L, LE, Text, R, RE, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) and then Raw_Bytes.Get (Raw, L.First) = '['
        and then Raw_Bytes.Get (Raw, L.Last) = ']'
      then
         Observe_Preserved_Items (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, For_References, For_Image, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Observe_Preserved_List;

   procedure Observe_Check_Items
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Raw_Scan.Valid (Raw, L) and then Valid (Text, R)
         and then Mixed_Field (Raw, LE, Text, RE)
         and then LP >= L.First + 1 and then LP <= Raw_Bytes.Length (Raw) + 1
         and then RP in R.First + 1 .. Text'Length + 1
         and then Projection_Observations.List_Items
           (Raw, L, LP, Raw_Scan.From_String (Text), Observation_Span (R), To_Big_Integer (RP)),
       Post => List_Items_Agreement (Raw, L, LE, LP, Text, R, RE, RP, False, Source => Source, Functions => Functions, Procedures => Procedures),
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Raw, L, LP);
      RM : constant Member := Item_Spec (Text, R, RP);
   begin
      Item_Observation (Text, R, RP);
      if LM.State = Raw_Scan.Present then
         Observe_Check_Record (Raw, LM.Value, LE, Text, RM.Value, RE, Source => Source, Functions => Functions, Procedures => Procedures);
         Observe_Check_Items (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Observe_Check_Items;

   procedure Observe_Check_List
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, LE, Text, RE)
         and then Raw_Field_Agreement
           (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R), Check_List_Value),
       Post => List_Observation_Agreement (Raw, L, LE, Text, R, RE, False, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if Raw_Scan.Valid (Raw, L) and then Raw_Bytes.Get (Raw, L.First) = '['
        and then Raw_Bytes.Get (Raw, L.Last) = ']'
      then
         Observe_Check_Items (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Observe_Check_List;

   procedure Mixed_Map_Name
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LM : Raw_Scan.Member;
      Text : String; R, RE : Span; RM : Member; Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE)
         and then LM.State = Raw_Scan.Present and then RM.State = Present
         and then Mixed_Content (Raw, LM.Key, Text, RM.Key)
         and then Mixed_Content (Raw, LM.Value, Text, RM.Value)
         and then Windows.Shifted_Span
           (LM.Value, Observation_Span (RM.Value), To_Big_Integer (R.First) - L.First),
       Post => Raw_Map_Name (Raw, L, LE, LM, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures) =
         Map_Name (Text, R, RE, RM, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if RM.Key.Last - RM.Key.First < 1 then return; end if;
      declare
         Name : constant String := Text (RM.Key.First + 1 .. RM.Key.Last - 1);
         LN : constant Raw_Scan.Span := (LM.Key.First + 1, LM.Key.Last - 1);
      begin
         if Coverage then
            Raw_Dynamic_Field (Raw, LE, LN, Name);
            Mixed_Preserved_Field (Raw, LE, Text, RE, Name);
            Mixed_Entity_Name (Raw, Raw_Field (Raw, LE, Name), Text, Field_Spec (Text, RE, Name), Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_String_Congruence
              (Raw, LM.Value, Text, RM.Value,
               Expected_Coverage (Raw_Entity_Name (Raw, Raw_Field (Raw, LE, Name), Source => Source, Functions => Functions, Procedures => Procedures), Kind, Functions => Functions, Procedures => Procedures));
         else
            Raw_Dynamic_Field (Raw, L, LN, Name);
            Mixed_Field_Shift (Raw, L, Text, R, Name);
            Mixed_Preserved_Field (Raw, L, Text, R, Name);
            pragma Assert ((Raw_Field (Raw, L, Name) = LM.Value) =
                           (Field_Spec (Text, R, Name) = RM.Value));
            Mixed_Entity_Name (Raw, LM.Value, Text, RM.Value, Source => Source, Functions => Functions, Procedures => Procedures);
         end if;
      end;
   end Mixed_Map_Name;

   procedure Mixed_Map_From
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset; Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE)
         and then RP in R.First + 1 .. R.Last + 1
         and then LP = L.First + To_Big_Integer (RP - R.First),
       Post => Raw_Map_From (Raw, L, LE, Kind, Coverage, LP, Source => Source, Functions => Functions, Procedures => Procedures) =
         Map_From (Text, R, RE, Kind, Coverage, RP, Source => Source, Functions => Functions, Procedures => Procedures),
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Member_Spec (Raw, L, LP);
      RM : constant Member := Member_Spec (Text, R, RP);
      Projected : constant Raw_Bytes.Sequence := Raw_Scan.From_String (Text);
   begin
      Mixed_To_Content (Raw, L, Text, R);
      Content_Window (Raw, L, Projected, Observation_Span (R));
      Windows.Member_Window (Raw, Projected, L.First, L.Last, LP, To_Big_Integer (R.First) - L.First);
      Member_Observation (Text, R, RP);
      if LM.State = Raw_Scan.Present then
         Member_Inside (Raw, L, LP);
         Window_Part (Raw, L, LM.Key, Projected, Observation_Span (R), Observation_Span (RM.Key));
         Content_Bounded (Raw, LM.Key, Text, RM.Key);
         Window_Part (Raw, L, LM.Value, Projected, Observation_Span (R), Observation_Span (RM.Value));
         Content_Bounded (Raw, LM.Value, Text, RM.Value);
         Mixed_Map_Name (Raw, L, LE, LM, Text, R, RE, RM, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures);
         Mixed_Map_From (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_Map_From;

   procedure Mixed_Map
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Kind : Audit_Kind; Coverage : Boolean;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE),
       Post => Raw_Map_Spec (Raw, L, LE, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures) = Map_Spec (Text, R, RE, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) and then Raw_Bytes.Get (Raw, L.First) = '{'
        and then Raw_Bytes.Get (Raw, L.Last) = '}'
      then
         Mixed_Map_From (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, Kind, Coverage, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_Map;

   procedure Mixed_Dependencies_From
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; LP : Raw_Scan.Offset;
      Text : String; R, RE : Span; RP : Offset;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Content (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE)
         and then RP in R.First + 1 .. R.Last + 1
         and then LP = L.First + To_Big_Integer (RP - R.First),
       Post => Raw_Dependencies_From (Raw, L, LE, LP, Source => Source, Functions => Functions, Procedures => Procedures) = Dependencies_From (Text, R, RE, RP, Source => Source, Functions => Functions, Procedures => Procedures),
       Subprogram_Variant => (Decreases => (Raw_Bytes.Length (Raw) + 1) - LP)
   is
      LM : constant Raw_Scan.Member := Raw_Scan.Item_Spec (Raw, L, LP);
      RM : constant Member := Item_Spec (Text, R, RP);
      Projected : constant Raw_Bytes.Sequence := Raw_Scan.From_String (Text);
   begin
      Mixed_To_Content (Raw, L, Text, R);
      Content_Window (Raw, L, Projected, Observation_Span (R));
      Windows.Item_Window (Raw, Projected, L.First, L.Last, LP, To_Big_Integer (R.First) - L.First);
      Item_Observation (Text, R, RP);
      if LM.State = Raw_Scan.Present then
         pragma Assert
           (LM.Next = L.First + To_Big_Integer (RM.Next - R.First));
         Item_Inside (Raw, L, LP);
         Window_Part (Raw, L, LM.Value, Projected, Observation_Span (R), Observation_Span (RM.Value));
         Content_Bounded (Raw, LM.Value, Text, RM.Value);
         Mixed_Preserved_Field (Raw, LM.Value, Text, RM.Value, JSON_claim);
         Observe_Reference
           (Raw, Raw_Field (Raw, LM.Value, JSON_claim), LE,
            Text, Field_Spec (Text, RM.Value, JSON_claim), RE, Source => Source, Functions => Functions, Procedures => Procedures);
         Mixed_Reference_Congruence
           (Raw, Raw_Field (Raw, LM.Value, JSON_claim), LE,
            Text, Field_Spec (Text, RM.Value, JSON_claim), RE, Source => Source, Functions => Functions, Procedures => Procedures);
         Mixed_Preserved_Field (Raw, LM.Value, Text, RM.Value, JSON_assumptions);
         Observe_Preserved_List
           (Raw, Raw_Field (Raw, LM.Value, JSON_assumptions), LE,
            Text, Field_Spec (Text, RM.Value, JSON_assumptions), RE, True, Source => Source, Functions => Functions, Procedures => Procedures);
         Mixed_List_Congruence
           (Raw, Raw_Field (Raw, LM.Value, JSON_assumptions), LE,
            Text, Field_Spec (Text, RM.Value, JSON_assumptions), RE, References, Source => Source, Functions => Functions, Procedures => Procedures);
         Mixed_Dependencies_From (Raw, L, LE, LM.Next, Text, R, RE, RM.Next, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_Dependencies_From;

   procedure Mixed_Dependencies
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Mixed_Field (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE),
       Post => Raw_Dependencies_Spec (Raw, L, LE, Source => Source, Functions => Functions, Procedures => Procedures) = Dependencies_Spec (Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      pragma Assert (Raw_Scan.Valid (Raw, L) = Valid (Text, R));
      if not Raw_Scan.Valid (Raw, L) then
         pragma Assert (not Raw_Dependencies_Spec (Raw, L, LE, Source => Source, Functions => Functions, Procedures => Procedures));
         pragma Assert (not Dependencies_Spec (Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures));
         return;
      end if;
      pragma Assert (Mixed_Content (Raw, L, Text, R));
      pragma Assert (Raw_Bytes.Get (Raw, L.First) = Text (R.First));
      pragma Assert (Raw_Bytes.Get (Raw, L.Last) = Text (R.Last));
      if Raw_Bytes.Get (Raw, L.First) /= '[' or else Raw_Bytes.Get (Raw, L.Last) /= ']' then
         pragma Assert (not Raw_Dependencies_Spec (Raw, L, LE, Source => Source, Functions => Functions, Procedures => Procedures));
         pragma Assert (not Dependencies_Spec (Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures));
         return;
      end if;
      Mixed_Dependencies_From (Raw, L, LE, L.First + 1, Text, R, RE, R.First + 1, Source => Source, Functions => Functions, Procedures => Procedures);
      pragma Assert (Raw_Dependencies_Spec (Raw, L, LE, Source => Source, Functions => Functions, Procedures => Procedures) =
                      Raw_Dependencies_From (Raw, L, LE, L.First + 1, Source => Source, Functions => Functions, Procedures => Procedures));
      pragma Assert (Dependencies_Spec (Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures) =
                      Dependencies_From (Text, R, RE, R.First + 1, Source => Source, Functions => Functions, Procedures => Procedures));
   end Mixed_Dependencies;

   function Object_Observation_Agreement
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span) return Boolean is
     (Mixed_Content (Raw, L, Text, R) or else Projection_Observations.Root_Objects
       (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R)))
     with Ghost => Static;

   procedure Mixed_Object_Field
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Name : String)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Name /= Projection_Observations.Flow_Name and then Name /= Projection_Observations.Proof_Name
         and then Object_Observation_Agreement (Raw, L, Text, R),
       Post => Mixed_Field (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name))
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Preserved_Field (Raw, L, Text, R, Name);
      else
         Root_Field_Queries
           (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
            To_Big_Integer (R.First) + 1, Name, Preserved_Value);
         Field_Query_Congruence
           (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
            To_Big_Integer (R.First) + 1, Name, Preserved_Value);
         Bounded_Field (Text, R, Name);
         Field_Bounded (Raw, Raw_Field (Raw, L, Name), Text, Field_Spec (Text, R, Name));
      end if;
   end Mixed_Object_Field;

   procedure Observe_Object_List
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span; Name : String;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then (Name = Projection_Observations.Flow_Name or else Name = Projection_Observations.Proof_Name)
         and then Object_Observation_Agreement (Raw, L, Text, R) and then Mixed_Field (Raw, LE, Text, RE),
       Post => List_Observation_Agreement
         (Raw, Raw_Field (Raw, L, Name), LE, Text, Field_Spec (Text, R, Name), RE, False, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) then
         Mixed_Preserved_Field (Raw, L, Text, R, Name);
         Observe_Preserved_List
           (Raw, Raw_Field (Raw, L, Name), LE, Text, Field_Spec (Text, R, Name), RE, False, Source => Source, Functions => Functions, Procedures => Procedures);
      else
         Root_Field_Queries
           (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
            To_Big_Integer (R.First) + 1, Name, Check_List_Value);
         Field_Query_Congruence
           (Raw, L, L.First + 1, Raw_Scan.From_String (Text), Observation_Span (R),
            To_Big_Integer (R.First) + 1, Name, Check_List_Value);
         Bounded_Field (Text, R, Name);
         Observe_Check_List (Raw, Raw_Field (Raw, L, Name), LE, Text, Field_Spec (Text, R, Name), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Observe_Object_List;

   procedure Mixed_Empty_Preserved
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length and then Mixed_Field (Raw, L, Text, R),
       Post => Raw_Empty_Array (Raw, L) = Empty_Array_Spec (Text, R)
   is
   begin
      if Mixed_Content (Raw, L, Text, R) and then Raw_Bytes.Get (Raw, L.First) = '['
        and then Raw_Bytes.Get (Raw, L.Last) = ']'
      then
         Mixed_To_Content (Raw, L, Text, R);
         Content_Window (Raw, L, Raw_Scan.From_String (Text), Observation_Span (R));
         Windows.Space_End_Equivalent
           (Raw, Raw_Scan.From_String (Text), L.First, L.Last, L.First + 1, To_Big_Integer (R.First) - L.First);
         Space_End_Observation (Text, R.First + 1);
      end if;
   end Mixed_Empty_Preserved;

   procedure Mixed_Empty_Observed
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then List_Observation_Agreement (Raw, L, LE, Text, R, RE, False, Source => Source, Functions => Functions, Procedures => Procedures),
       Post => Raw_Empty_Array (Raw, L) = Empty_Array_Spec (Text, R)
   is
   begin
      null;
   end Mixed_Empty_Observed;

   procedure Projection_Field_Names
     with Ghost => Static, Global => null,
       Post => JSON_flow = Projection_Observations.Flow_Name
         and then JSON_proof = Projection_Observations.Proof_Name
   is
   begin
      null;
   end Projection_Field_Names;

   procedure Observe_Proof_List
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Object_Observation_Agreement (Raw, L, Text, R)
         and then Mixed_Field (Raw, LE, Text, RE),
       Post => List_Observation_Agreement
         (Raw, Raw_Field (Raw, L, JSON_proof), LE,
          Text, Field_Spec (Text, R, JSON_proof), RE, False, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Projection_Field_Names;
      Observe_Object_List (Raw, L, LE, Text, R, RE, JSON_proof, Source => Source, Functions => Functions, Procedures => Procedures);
   end Observe_Proof_List;

   procedure Observe_Flow_List
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Object_Observation_Agreement (Raw, L, Text, R)
         and then Mixed_Field (Raw, LE, Text, RE),
       Post => List_Observation_Agreement
         (Raw, Raw_Field (Raw, L, JSON_flow), LE,
          Text, Field_Spec (Text, R, JSON_flow), RE, False, Source => Source, Functions => Functions, Procedures => Procedures)
   is
   begin
      Projection_Field_Names;
      Observe_Object_List (Raw, L, LE, Text, R, RE, JSON_flow, Source => Source, Functions => Functions, Procedures => Procedures);
   end Observe_Flow_List;

   --  Transfer the complete function witness requirement in a small proof
   --  context, then use its Boolean equality in the complete object policy.
   procedure Mixed_Termination_Witnesses
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then List_Observation_Agreement
           (Raw, L, LE, Text, R, RE, False, Source => Source, Functions => Functions, Procedures => Procedures),
       Post =>
         (for all I in 1 .. Functions.Count => Raw_List_Spec
           (Raw, L, LE, Argument_Postconditions + I, Source => Source, Functions => Functions, Procedures => Procedures)) =
         (for all I in 1 .. Functions.Count => List_Spec
           (Text, R, RE, Argument_Postconditions + I, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      --  The callee proves exact predicate equality. Keep the quantified
      --  transfer at that predicate boundary instead of expanding its bodies.
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", Raw_List_Spec);
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", List_Spec);
   begin
      for I in 1 .. Functions.Count loop
         Mixed_List_Congruence
           (Raw, L, LE, Text, R, RE, Argument_Postconditions + I,
            Source => Source, Functions => Functions, Procedures => Procedures);
         pragma Loop_Invariant (for all J in 1 .. I =>
           Raw_List_Spec (Raw, L, LE, Argument_Postconditions + J,
             Source => Source, Functions => Functions, Procedures => Procedures) =
           List_Spec (Text, R, RE, Argument_Postconditions + J,
             Source => Source, Functions => Functions, Procedures => Procedures));
      end loop;
   end Mixed_Termination_Witnesses;

   procedure Mixed_Initialization_Witnesses
     (Raw : Raw_Bytes.Sequence; L, LE : Raw_Scan.Span; Text : String; R, RE : Span;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then List_Observation_Agreement
           (Raw, L, LE, Text, R, RE, False, Source => Source, Functions => Functions, Procedures => Procedures),
       Post =>
         (for all I in 1 .. Procedures.Parameter_Count =>
           (if Required_Output (I, Procedures) then Raw_List_Spec
             (Raw, L, LE, Initialization_Witness_Base + I, Source => Source, Functions => Functions, Procedures => Procedures))) =
         (for all I in 1 .. Procedures.Parameter_Count =>
           (if Required_Output (I, Procedures) then List_Spec
             (Text, R, RE, Initialization_Witness_Base + I, Source => Source, Functions => Functions, Procedures => Procedures)))
   is
      --  The callee proves exact predicate equality. Keep the quantified
      --  transfer at that predicate boundary instead of expanding its bodies.
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", Raw_List_Spec);
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", List_Spec);
   begin
      for I in 1 .. Procedures.Parameter_Count loop
         Mixed_List_Congruence
           (Raw, L, LE, Text, R, RE, Initialization_Witness_Base + I,
            Source => Source, Functions => Functions, Procedures => Procedures);
         pragma Loop_Invariant (for all J in 1 .. I =>
           Raw_List_Spec (Raw, L, LE, Initialization_Witness_Base + J,
             Source => Source, Functions => Functions, Procedures => Procedures) =
           List_Spec (Text, R, RE, Initialization_Witness_Base + J,
             Source => Source, Functions => Functions, Procedures => Procedures));
      end loop;
   end Mixed_Initialization_Witnesses;

   procedure Mixed_Object
     (Raw : Raw_Bytes.Sequence; L : Raw_Scan.Span; Text : String; R : Span; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Object_Observation_Agreement (Raw, L, Text, R),
       Post => Raw_Object_Policy (Raw, L, Kind, Source => Source, Functions => Functions, Procedures => Procedures) = Object_Policy (Text, R, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
   is
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", Raw_List_Spec);
      pragma Annotate
        (GNATprove, Hide_Info, "Expression_Function_Body", List_Spec);
      LE : constant Raw_Scan.Span := Raw_Field (Raw, L, JSON_entities);
      RE : constant Span := Field_Spec (Text, R, JSON_entities);
      Flow_Kind : constant List_Kind :=
          (if Kind in Main_Body | Main_Put | Main_Mixed | Argument_Effects | Argument_Binding_Main
                 | Argument_Without_Query | Argument_Put_Without_Query | Argument_Mixed_Without_Query
                 | Argument_Effects_Without_Query then Argument_Diagnostics
           elsif Kind in Selected_Main | Selected_Put | Selected_Mixed | Selected_Effects | Selected_Binding_Main
                 | Selected_Without_Query | Selected_Put_Without_Query | Selected_Mixed_Without_Query
                 | Selected_Effects_Without_Query then Selected_Diagnostics
           elsif Kind in Mutable_Audit then Assignment_Diagnostics
           elsif Kind in Application_Audit then Binding_Diagnostics else Checks);
   begin
      Projection_Field_Names;
      Mixed_Object_Field (Raw, L, Text, R, JSON_entities);
      Mixed_Object_Field (Raw, L, Text, R, JSON_progress);
      Mixed_Object_Field (Raw, L, Text, R, JSON_stop_reason);
      Mixed_Object_Field (Raw, L, Text, R, JSON_skip_flow_proof);
      Mixed_Object_Field (Raw, L, Text, R, JSON_skip_proof);
      Mixed_Object_Field (Raw, L, Text, R, JSON_pragma_assume);
      Mixed_Object_Field (Raw, L, Text, R, JSON_warn_error);
      Mixed_Object_Field (Raw, L, Text, R, JSON_spark);
      Mixed_Object_Field (Raw, L, Text, R, JSON_assumptions);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_progress), Text, Field_Spec (Text, R, JSON_progress), Atom_PROGRESS_PROOF);
      Mixed_String_Congruence
        (Raw, Raw_Field (Raw, L, JSON_stop_reason), Text, Field_Spec (Text, R, JSON_stop_reason), Atom_STOP_REASON_NONE);
      Mixed_Empty_Preserved (Raw, Raw_Field (Raw, L, JSON_skip_flow_proof), Text, Field_Spec (Text, R, JSON_skip_flow_proof));
      Mixed_Empty_Preserved (Raw, Raw_Field (Raw, L, JSON_skip_proof), Text, Field_Spec (Text, R, JSON_skip_proof));
      Mixed_Empty_Preserved (Raw, Raw_Field (Raw, L, JSON_pragma_assume), Text, Field_Spec (Text, R, JSON_pragma_assume));
      Mixed_Empty_Preserved (Raw, Raw_Field (Raw, L, JSON_warn_error), Text, Field_Spec (Text, R, JSON_warn_error));
      Observe_Preserved_List
        (Raw, Raw_Field (Raw, L, JSON_warn_error), LE, Text, Field_Spec (Text, R, JSON_warn_error), RE, False, True, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_List_Congruence
        (Raw, Raw_Field (Raw, L, JSON_warn_error), LE, Text, Field_Spec (Text, R, JSON_warn_error), RE, Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Map (Raw, LE, LE, Text, RE, RE, Kind, False, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Map (Raw, Raw_Field (Raw, L, JSON_spark), LE, Text, Field_Spec (Text, R, JSON_spark), RE, Kind, True, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Dependencies (Raw, Raw_Field (Raw, L, JSON_assumptions), LE,
                          Text, Field_Spec (Text, R, JSON_assumptions), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Observe_Flow_List (Raw, L, LE, Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Termination_Witnesses
        (Raw, Raw_Field (Raw, L, JSON_flow), LE,
         Text, Field_Spec (Text, R, JSON_flow), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Initialization_Witnesses
        (Raw, Raw_Field (Raw, L, JSON_flow), LE,
         Text, Field_Spec (Text, R, JSON_flow), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Observe_Proof_List (Raw, L, LE, Text, R, RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Empty_Observed (Raw, Raw_Field (Raw, L, JSON_flow), LE, Text, Field_Spec (Text, R, JSON_flow), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_Empty_Observed (Raw, Raw_Field (Raw, L, JSON_proof), LE, Text, Field_Spec (Text, R, JSON_proof), RE, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_List_Congruence (Raw, Raw_Field (Raw, L, JSON_flow), LE,
                             Text, Field_Spec (Text, R, JSON_flow), RE, Flow_Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_List_Congruence (Raw, Raw_Field (Raw, L, JSON_proof), LE,
                             Text, Field_Spec (Text, R, JSON_proof), RE,
                             (if Kind in Application_Audit then Main_Checks else Checks), Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_List_Congruence (Raw, Raw_Field (Raw, L, JSON_proof), LE,
                             Text, Field_Spec (Text, R, JSON_proof), RE,
                             (if Kind = IO_Body then Postconditions else Argument_Postconditions), Source => Source, Functions => Functions, Procedures => Procedures);
      Mixed_List_Congruence (Raw, Raw_Field (Raw, L, JSON_proof), LE,
                             Text, Field_Spec (Text, R, JSON_proof), RE, Put_Postconditions, Source => Source, Functions => Functions, Procedures => Procedures);
   end Mixed_Object;

   procedure Mixed_Report
     (Raw : Raw_Bytes.Sequence; Text : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
         and then Projection_Observations.Audit_Projection_Observations (Raw, Raw_Scan.From_String (Text)),
       Post => Raw_Report_Policy (Raw, Kind, Source => Source, Functions => Functions, Procedures => Procedures) = Report_Policy (Text, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
   is
      use type Raw_Bytes.Sequence;
      Start : constant Offset := Space_End (Text, 1);
      Last : constant Offset := Value_Spec (Text, Start);
      Raw_Start : constant Raw_Scan.Offset := Raw_Scan.Space_End (Raw, 1);
      Raw_Last : constant Raw_Scan.Offset := Raw_Scan.Value_Spec (Raw, Raw_Start);
   begin
      Space_End_Observation (Text, 1);
      Value_Spec_Observation (Text, Start);
      if Last /= 0 then Space_End_Observation (Text, Last + 1); end if;
      if Raw = Raw_Scan.From_String (Text) then
         if Last /= 0 and then Space_End (Text, Last + 1) = Text'Length + 1 then
            Identity_Field (Text, (Start, Last));
            Mixed_Object (Raw, (Raw_Start, Raw_Last), Text, (Start, Last), Kind, Source => Source, Functions => Functions, Procedures => Procedures);
         end if;
      else
         Mixed_Object (Raw, (Raw_Start, Raw_Last), Text, (Start, Last), Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Mixed_Report;

   function Runtime_Report_Policy (Report : String; Kind : Report_Kind)
     return Boolean is
     (Report'Length <= Max_Runtime_Report_Length
      and then Report_Policy (Report, Audit_Of (Kind), Atom_Empty, Empty_Functions, Empty_Procedures));

   function Application_Report_Policy
     (Report : String; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures) return Boolean is
     (case Kind is
        when Static_Output => Report_Policy (Report, Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Static_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Static_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Static_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Argument_Output => Report_Policy (Report, Argument_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Argument_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Main_Body, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Main_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Main_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Argument_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Argument_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Argument_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Argument_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures),
        when Assigned_Output => Report_Policy (Report, Assignment_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Assignment_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Assignment_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Assignment_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Selected_Output => Report_Policy (Report, Selected_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Report_Policy (Report, Selected_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures));

   procedure Application_Projection_Correspondence
     (Original : Raw_Bytes.Sequence; Projected : String; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures)
   is
   begin
      case Kind is
         when Static_Output =>
            Mixed_Report (Original, Projected, Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Static_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Static_Put, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Static_Mixed, Source => Source, Functions => Functions, Procedures => Procedures);
         when Argument_Output =>
            Mixed_Report (Original, Projected, Argument_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Argument_Effects, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Main_Body, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Main_Put, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Main_Mixed, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Argument_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Argument_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Argument_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Argument_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
         when Assigned_Output =>
            Mixed_Report (Original, Projected, Assignment_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Assignment_Effects, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Assignment_Put, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Assignment_Mixed, Source => Source, Functions => Functions, Procedures => Procedures);
         when Selected_Output =>
            Mixed_Report (Original, Projected, Selected_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Effects, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Main, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Put, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Mixed, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
            Mixed_Report (Original, Projected, Selected_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures);
      end case;
   end Application_Projection_Correspondence;

   procedure Runtime_Projection_Correspondence
     (Original : Raw_Bytes.Sequence; Projected : String; Kind : Report_Kind)
   is
   begin
      Mixed_Report (Original, Projected, Audit_Of (Kind), Atom_Empty, Empty_Functions, Empty_Procedures);
   end Runtime_Projection_Correspondence;

   function Audit_Normalized_Report (Text : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Text'First = 1,
       Post => (Static => Audit_Normalized_Report'Result = Report_Policy (Text, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
   is
   begin
      if Text'Length not in 1 .. Max_Report_Length then return False; end if;
      declare
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
           and then (if Kind in Application_Audit then
             List_OK (Text, Field (Text, Object, JSON_warn_error), Entities, Main_Advisories, Source => Source, Functions => Functions, Procedures => Procedures)
             else Empty_Array (Text, Field (Text, Object, JSON_warn_error)))
           and then Entities_OK (Text, Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
           and then Coverage_OK (Text, Field (Text, Object, JSON_spark), Entities, Kind, Source => Source, Functions => Functions, Procedures => Procedures)
           and then List_OK (Text, Field (Text, Object, JSON_flow), Entities,
             (if Kind in Main_Body | Main_Put | Main_Mixed | Argument_Effects | Argument_Binding_Main
                 | Argument_Without_Query | Argument_Put_Without_Query | Argument_Mixed_Without_Query
                 | Argument_Effects_Without_Query then Argument_Diagnostics
              elsif Kind in Selected_Main | Selected_Put | Selected_Mixed | Selected_Effects | Selected_Binding_Main
                 | Selected_Without_Query | Selected_Put_Without_Query | Selected_Mixed_Without_Query
                 | Selected_Effects_Without_Query then Selected_Diagnostics
              elsif Kind in Mutable_Audit then Assignment_Diagnostics
              elsif Kind in Application_Audit then Binding_Diagnostics else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
           and then List_OK (Text, Field (Text, Object, JSON_proof), Entities,
                             (if Kind in Application_Audit then Main_Checks else Checks), Source => Source, Functions => Functions, Procedures => Procedures)
           and then (if Kind in Application_Audit then
          (for all I in 1 .. Functions.Count => List_OK
            (Text, Field (Text, Object, JSON_flow), Entities, Argument_Postconditions + I, Source => Source, Functions => Functions, Procedures => Procedures)) and then
          (for all I in 1 .. Procedures.Parameter_Count =>
             (if Required_Output (I, Procedures) then List_OK
               (Text, Field (Text, Object, JSON_flow), Entities, Initialization_Witness_Base + I,
                Source => Source, Functions => Functions, Procedures => Procedures))))
        and then Dependencies_OK (Text, Field (Text, Object, JSON_assumptions), Entities, Source => Source, Functions => Functions, Procedures => Procedures)
           and then (Kind in Libc_Interface | Argv_Interface | Application_Audit or else
             (not Empty_Array (Text, Field (Text, Object, JSON_flow))
              and then not Empty_Array (Text, Field (Text, Object, JSON_proof))
              and then List_OK (Text, Field (Text, Object, JSON_proof), Entities,
                (if Kind = IO_Body then Postconditions else Argument_Postconditions), Source => Source, Functions => Functions, Procedures => Procedures)
              and then (if Kind = IO_Body then List_OK
                (Text, Field (Text, Object, JSON_proof), Entities, Put_Postconditions, Source => Source, Functions => Functions, Procedures => Procedures))));
      end;
   end Audit_Normalized_Report;

   procedure Report_Rebase_Policy
     (Report : String; Kind : Audit_Kind; Source : String;
      Functions : Function_Metadata; Procedures : Procedure_Metadata)
     with Ghost => Static, Global => null,
       Pre => Report'Length in 1 .. Max_Report_Length,
       Post =>
         (declare Text : constant String (1 .. Report'Length) := Report;
          begin Report_Policy (Report, Kind, Source => Source, Functions => Functions, Procedures => Procedures) =
            Report_Policy (Text, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
   is
   begin
      null;
   end Report_Rebase_Policy;

   --  Keep the uncommon rebasing copy in its own call frame. The driver and
   --  runtime-evidence reader already supply slices starting at one.
   function Audit_Rebased_Report (Report : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Pre => Report'Length in 1 .. Max_Report_Length,
       Post => (Static => Audit_Rebased_Report'Result = Report_Policy (Report, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
   is
      Text : constant String (1 .. Report'Length) := Report;
   begin
      Report_Rebase_Policy (Report, Kind, Source, Functions, Procedures);
      return Audit_Normalized_Report (Text, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
   end Audit_Rebased_Report;

   function Audit_Report (Report : String; Kind : Audit_Kind;
      Source : String; Functions : Function_Metadata; Procedures : Procedure_Metadata) return Boolean
     with Post => (Static => Audit_Report'Result = Report_Policy (Report, Kind, Source => Source, Functions => Functions, Procedures => Procedures))
   is
   begin
      if Report'Length not in 1 .. Max_Report_Length then return False; end if;
      if Report'First = 1 then
         return Audit_Normalized_Report (Report, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      else
         return Audit_Rebased_Report (Report, Kind, Source => Source, Functions => Functions, Procedures => Procedures);
      end if;
   end Audit_Report;

   function Complete_Runtime_Proof
     (Report : String; Kind : Report_Kind) return Boolean is
   begin
      return Report'Length <= Max_Runtime_Report_Length and then Audit_Report (Report, Audit_Of (Kind), Atom_Empty, Empty_Functions, Empty_Procedures);
   end Complete_Runtime_Proof;
   function Complete_Application_Proof
     (Report : String; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures) return Boolean is
   begin
      return (case Kind is
        when Static_Output => Audit_Report (Report, Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Static_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Static_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Static_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Argument_Output => Audit_Report (Report, Argument_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Argument_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Main_Body, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Main_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Main_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Argument_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Argument_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Argument_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Argument_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures),
        when Assigned_Output => Audit_Report (Report, Assignment_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Assignment_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Assignment_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Assignment_Mixed, Source => Source, Functions => Functions, Procedures => Procedures),
        when Selected_Output => Audit_Report (Report, Selected_Binding_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Effects, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Main, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Put, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Mixed, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Put_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Mixed_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures)
          or else Audit_Report (Report, Selected_Effects_Without_Query, Source => Source, Functions => Functions, Procedures => Procedures));
   end Complete_Application_Proof;
end Silver_Library_Reports;
