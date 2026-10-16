package body Silver_Report_Projection_Bridge with SPARK_Mode => On is
   procedure Reachable_Context (Raw : Bytes.Sequence; Count : Big_Natural) is
   begin
      if Count = 0 then
         Structure.Initial_Context;
      else
         Reachable_Context (Raw, Count - 1);
         Structure.Advance_Context
           (Model.Scan_State (Raw, Count - 1), Bytes.Get (Raw, Count));
      end if;
   end Reachable_Context;

   procedure Failed_Persists
     (Raw : Bytes.Sequence; First, Last : Big_Natural) is
   begin
      if Last > First then
         Failed_Persists (Raw, First, Last - 1);
      end if;
   end Failed_Persists;

   procedure Prefix_Context (Raw : Bytes.Sequence; Count : Big_Natural) is
   begin
      Reachable_Context (Raw, Count);
      Failed_Persists (Raw, Count, Bytes.Length (Raw));
   end Prefix_Context;

   procedure Container_Frames (S : State; Item : Character)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => (for all I in 1 .. S.Depth =>
         (if I <= Model.Advance_Spec (S, Item).Following.Depth then
           S.Stack (I).Container = Model.Advance_Spec (S, Item).Following.Stack (I).Container))
   is
   begin
      null;
   end Container_Frames;

   procedure Container_String_Step
     (S : State; Item : Character; Base : Depth_Range;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level; Escaped : Boolean)
   is
   begin
      Container_Frames (S, Item);
   end Container_String_Step;

   procedure Structural_Step
     (S : State; Item : Character; Base : Depth_Range;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
   is
   begin
      Container_Frames (S, Item);
      case S.Mode is
         when Between_Tokens => null;
         when In_Number =>
            if Item in '"' | '{' | '[' | '}' | ']' then
               case S.Number is
                  when After_Zero | Integer_Digits | Fraction_Digits | Exponent_Digits =>
                     pragma Assert (Model.Number_Ends (S.Number, Item));
                  when others => pragma Assert (False);
               end case;
               pragma Assert (Item in '}' | ']');
            end if;
         when In_Literal =>
            pragma Assert (Item not in '"' | '{' | '[' | '}' | ']');
         when others => pragma Assert (False);
      end case;
   end Structural_Step;

   procedure Container_Head
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Base : Depth_Range; Kind : Container_Kind)
     with Pre => First >= 1 and then First <= Last and then Last <= Bytes.Length (Raw)
       and then Base < Max_Depth
       and then Model.Scan_State (Raw, First - 1).Depth > Base
       and then Model.Scan_State (Raw, First - 1).Stack (Base + 1).Container = Kind
       and then (for all I in Raw => (if First < I and then I <= Last then
         Model.Scan_State (Raw, I - 1).Depth > Base
         and then Model.Scan_State (Raw, I - 1).Stack (Base + 1).Container = Kind)),
       Post => (for all I in Raw => (if First <= I and then I <= Last then
         Model.Scan_State (Raw, I - 1).Depth > Base
         and then Model.Scan_State (Raw, I - 1).Stack (Base + 1).Container = Kind))
   is
   begin
      null;
   end Container_Head;

   procedure Container_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural;
      Base : Depth_Range; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped : Boolean)
   is
      Current : constant State := Model.Scan_State (Raw, Position - 1);
      Last : constant Big_Natural := Observations.Value_From
        (Raw, Start, Position, Openers, Level, Quoted, Escaped, True);
   begin
      Prefix_Context (Raw, Position - 1);
      pragma Assert (Position <= Bytes.Length (Raw));
      Prefix_Context (Raw, Position);
      declare
         Item : constant Character := Bytes.Get (Raw, Position);
         Next : constant State := Model.Scan_State (Raw, Position);
         Next_Openers : Observations.Nesting := Openers;
         Next_Level : Observations.Nesting_Level := Level;
         Next_Quoted : Boolean := False;
         Next_Escaped : Boolean := False;
         Done : Boolean := False;
      begin
         pragma Assert (Next = Model.Advance_Spec (Current, Item).Following);
         Container_Frames (Current, Item);
         Parents.Inside_Container (Current, Item, Base);
         pragma Assert (Parents.Same (Current, Next, Base));
         pragma Assert (if Next.Depth > Base then Parents.Whole (Current, Next, Base));
         if Quoted then
            Container_String_Step (Current, Item, Base, Openers, Level, Escaped);
            Next_Quoted := Escaped or else Item /= '"';
            Next_Escaped := not Escaped and then Item = '\';
         else
            pragma Assert (not Escaped);
            Structural_Step (Current, Item, Base, Openers, Level);
            if Item = '"' then
               Next_Quoted := True;
            elsif Item in '{' | '[' then
               pragma Assert (Level < Max_Depth);
               Next_Level := Level + 1;
               Next_Openers := Observations.Pushed (Openers, Next_Level, Item);
            elsif Item in '}' | ']' then
               if Level = 1 then
                  Done := True;
               else
                  Next_Level := Level - 1;
               end if;
            end if;
         end if;
         if Done then
            pragma Assert (Last = Position);
            pragma Assert (End_Context (Next, Base));
         else
            pragma Assert (Container_Context
              (Next, Base, Next_Openers, Next_Level, Next_Quoted, Next_Escaped));
            pragma Assert (Last = Observations.Value_From
              (Raw, Start, Position + 1, Next_Openers, Next_Level, Next_Quoted, Next_Escaped, True));
            Container_End
              (Raw, Start, Position + 1, Base, Next_Openers, Next_Level, Next_Quoted, Next_Escaped);
            Parents.Same_Transitive (Current, Next, Model.Scan_State (Raw, Last), Base);
            Parents.Lift_Whole (Raw, Position + 1, Last, Current, Next, Base);
         end if;
         Container_Head (Raw, Position, Last, Base, Current.Stack (Base + 1).Container);
         Parents.Whole_Head (Raw, Position, Last, Current, Base);
      end;
   end Container_End;
end Silver_Report_Projection_Bridge;
