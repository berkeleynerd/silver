with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Tokens;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Parents;
with Silver_Report_Observation_Composition;

package body Silver_Report_Projection_Continuations with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Tokens renames Silver_Report_Projection_Tokens;
   package Structure renames Silver_Report_Projection_Structure;
   package Parents renames Silver_Report_Projection_Parents;
   package Composition renames Silver_Report_Observation_Composition;

   function Coupled
     (Raw_Openers, Target_Openers, Final_Openers : Observations.Nesting;
      Outer, Level : Observations.Nesting_Level) return Boolean is
     (Outer > 0 and then Outer + Level <= 64
      and then Composition.Same_Prefix (Target_Openers, Final_Openers, Outer)
      and then (for all I in 1 .. Level =>
        Raw_Openers (I) = Target_Openers (Outer + I)));

   procedure Container_Continuation
     (Raw, Target : Bytes.Sequence; First, Position, Last, Outer_Start : Big_Natural;
      Shift : Big_Integer; Base : Depth_Range;
      Raw_Openers, Target_Openers, Final_Openers : Observations.Nesting;
      Outer, Level : Observations.Nesting_Level; Quoted, Escaped : Boolean)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then First >= 1 and then First < Position
         and then Position <= Bytes.Length (Raw) + 1
         and then Windows.Same_Window (Raw, Target, First, Last, Shift)
         and then Outer_Start >= 1 and then Outer_Start <= First + Shift
         and then Outer <= Base
         and then Bridge.Container_Context
           (Model.Scan_State (Raw, Position - 1), Base, Raw_Openers, Level, Quoted, Escaped)
         and then Observations.Value_From
           (Raw, First, Position, Raw_Openers, Level, Quoted, Escaped, True) = Last
         and then Coupled (Raw_Openers, Target_Openers, Final_Openers, Outer, Level),
       Post => Observations.Value_From
         (Target, Outer_Start, Position + Shift, Target_Openers,
          Outer + Level, Quoted, Escaped, True) =
           Observations.Value_From
         (Target, Outer_Start, Last + Shift + 1, Final_Openers, Outer, False, False, True),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position)
   is
      Current : constant State := Model.Scan_State (Raw, Position - 1);
   begin
      Bridge.Container_End (Raw, First, Position, Base, Raw_Openers, Level, Quoted, Escaped);
      Bridge.Prefix_Context (Raw, Position - 1);
      pragma Assert (Position <= Last);
      Bridge.Prefix_Context (Raw, Position);
      pragma Assert (Bytes.Get (Raw, Position) = Bytes.Get (Target, Position + Shift));
      declare
         Item : constant Character := Bytes.Get (Raw, Position);
         Next : constant State := Model.Scan_State (Raw, Position);
      begin
         pragma Assert (Next = Model.Advance_Spec (Current, Item).Following);
         if Quoted then
            Bridge.Container_String_Step (Current, Item, Base, Raw_Openers, Level, Escaped);
            if Escaped then
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, True, False);
            elsif Item = '\' then
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, True, True);
            elsif Item = '"' then
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, False, False);
            else
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, True, False);
            end if;
         else
            pragma Assert (not Escaped);
            Bridge.Structural_Step (Current, Item, Base, Raw_Openers, Level);
            if Item = '"' then
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, True, False);
            elsif Item in '{' | '[' then
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Observations.Pushed (Raw_Openers, Level + 1, Item),
                  Observations.Pushed (Target_Openers, (Outer + Level) + 1, Item),
                  Final_Openers, Outer, Level + 1, False, False);
            elsif Item in '}' | ']' then
               pragma Assert ((Item = '}' and then Target_Openers (Outer + Level) = '{')
                 or else (Item = ']' and then Target_Openers (Outer + Level) = '['));
               if Level = 1 then
                  pragma Assert (Last = Position);
                  Composition.Prefix_Insensitive
                    (Target, Outer_Start, Last + Shift + 1, Target_Openers,
                     Final_Openers, Outer, False, False, True);
               else
                  Container_Continuation
                    (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                     Raw_Openers, Target_Openers, Final_Openers, Outer, Level - 1, False, False);
               end if;
            else
               Container_Continuation
                 (Raw, Target, First, Position + 1, Last, Outer_Start, Shift, Base,
                  Raw_Openers, Target_Openers, Final_Openers, Outer, Level, False, False);
            end if;
         end if;
      end;
   end Container_Continuation;

   procedure Primitive_Byte (S : State; Item : Character)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then S.Mode in In_Number | In_Literal
       and then (if S.Mode = In_Number then not Model.Number_Ends (S.Number, Item))
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Item not in '"' | '{' | '[' | '}' | ']'
   is
   begin
      null;
   end Primitive_Byte;

   procedure Primitive_Interior (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Pre => Bridge.Complete (Raw) and then First >= 1
       and then First <= Last + 1 and then Last <= Bytes.Length (Raw)
       and then (for all I in Raw =>
         (if First <= I and then I <= Last then
           Model.Scan_State (Raw, I - 1).Mode in In_Number | In_Literal
           and then (if Model.Scan_State (Raw, I - 1).Mode = In_Number then
             not Model.Number_Ends (Model.Scan_State (Raw, I - 1).Number, Bytes.Get (Raw, I))))),
       Post => (for all I in Raw =>
         (if First <= I and then I <= Last then
           Bytes.Get (Raw, I) not in '"' | '{' | '[' | '}' | ']')),
       Subprogram_Variant => (Decreases => Last + 1 - First)
   is
   begin
      if First <= Last then
         Primitive_Interior (Raw, First + 1, Last);
         Bridge.Prefix_Context (Raw, First - 1);
         Bridge.Prefix_Context (Raw, First);
         Primitive_Byte (Model.Scan_State (Raw, First - 1), Bytes.Get (Raw, First));
      end if;
   end Primitive_Interior;

   procedure Retained_Value_Skip
     (Raw, Target : Bytes.Sequence; First, Last, Outer_Start : Big_Natural;
      Shift : Big_Integer; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level)
   is
      Before : constant State := Model.Scan_State (Raw, First - 1);
      Item : constant Character := Bytes.Get (Raw, First);
      Base : constant Depth_Range := Before.Depth;
   begin
      Values.Value_Boundary (Raw, First);
      Bridge.Prefix_Context (Raw, First - 1);
      Bridge.Prefix_Context (Raw, First);
      pragma Assert (Item = Bytes.Get (Target, First + Shift));
      if Item in '{' | '[' then
         pragma Assert (Observations.Value_From
           (Target, Outer_Start, First + Shift, Openers, Level, False, False, True) =
             Observations.Value_From
           (Target, Outer_Start, First + Shift + 1,
            Observations.Pushed (Openers, Level + 1, Bytes.Get (Target, First + Shift)),
            Level + 1, False, False, True));
         Container_Continuation
           (Raw, Target, First, First + 1, Last, Outer_Start, Shift, Base,
            Observations.Pushed (Observations.Empty_Nesting, 1, Item),
            Observations.Pushed (Openers, Level + 1, Bytes.Get (Target, First + Shift)),
            Openers, Level, 1, False, False);
         pragma Assert (Observations.Value_From
           (Target, Outer_Start, First + Shift, Openers, Level, False, False, True) =
             Observations.Value_From
           (Target, Outer_Start, Last + Shift + 1, Openers, Level, False, False, True));
      elsif Item = '"' then
         Windows.Closed_Value_Window (Raw, Target, First, Last, First, Shift);
         Composition.Quoted_Skip (Target, Outer_Start, First + Shift, Last + Shift, Openers, Level);
      else
         Tokens.Primitive_End (Raw, First, First + 1, Base);
         Primitive_Interior (Raw, First + 1, Last);
         pragma Assert (for all I in Raw =>
           (if First <= I and then I <= Last then
             Bytes.Get (Raw, I) not in '"' | '{' | '[' | '}' | ']'));
         pragma Assert (for all I in Target =>
           (if First + Shift <= I and then I <= Last + Shift then
             Bytes.Get (Target, I) not in '"' | '{' | '[' | '}' | ']'));
         Composition.Plain_Skip
           (Target, Outer_Start, First + Shift, Last + Shift + 1, Openers, Level);
      end if;
   end Retained_Value_Skip;
end Silver_Report_Projection_Continuations;
