with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Members;
with Silver_Report_Projection_Keys;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Container_Mapping;
with Silver_Report_Projection_Member_Mapping;
with Silver_Report_Projection_Value_Mapping;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Items;
with Silver_Report_Observation_Traversal;
with Silver_Report_Observation_Composition;
package body Silver_Report_Projection_Records with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Structure renames Silver_Report_Projection_Structure;
   package Members renames Silver_Report_Projection_Members;
   package Keys renames Silver_Report_Projection_Keys;
   package Spans renames Silver_Report_Projection_Spans;
   package Containers renames Silver_Report_Projection_Container_Mapping;
   package Member_Mapping renames Silver_Report_Projection_Member_Mapping;
   package Value_Mapping renames Silver_Report_Projection_Value_Mapping;
   package Values renames Silver_Report_Projection_Values;
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Items renames Silver_Report_Observation_Items;
   package Traversal renames Silver_Report_Observation_Traversal;
   package Composition renames Silver_Report_Observation_Composition;
   use type Scan.Member_State;

   procedure Tree_Context (S : State)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Depth = 3 and then S.Stack (3).Role = Check_Record
         and then Structure.Awaits_Value (S.Stack (3)) and then S.Stack (3).Key = Tree_Key,
       Post => Structure.Tree_Value_Context (S)
   is
   begin
      pragma Assert (S.Stack (3).Container = Object_Container);
      pragma Assert (S.Stack (3).Position = Object_Value);
      pragma Assert (Structure.Frame_Valid (S, 2));
      pragma Assert (Structure.Frame_Valid (S, 1));
   end Tree_Context;

   --  Establish both the observed value and its behavior inside an enclosing
   --  scanner from the original value context, before assembling its member.
   procedure Value_Projection
     (Raw : Bytes.Sequence; Value : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Scan.Valid (Raw, Value) and then Values.Ready (Raw, Value.First)
         and then Value.Last = Scan.Value_Spec (Raw, Value.First)
         and then Model.Scan_State (Raw, Value.First - 1).Depth = 3
         and then Model.Scan_State (Raw, Value.First - 1).Stack (3).Role = Check_Record
         and then Value.Last < Bytes.Length (Raw)
         and then Spans.Retained (Raw, Value.Last + 1, Value.Last + 1)
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Value.First)
         and then Level in 1 .. 3,
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Value.First, Value.Last))
         and then
           (if Model.Scan_State (Raw, Value.First - 1).Stack (3).Key = Tree_Key then
              Relations.Empty_Object (Mapping.Output (Raw), Mapping.Mapped (Raw, Value.First, Value.Last))
            else Relations.Same_Content
              (Raw, Value, Mapping.Output (Raw), Mapping.Mapped (Raw, Value.First, Value.Last)))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Value.First)) =
           Mapping.Last (Raw, Value.Last)
         and then Scan.Value_From
           (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Value.First),
            Openers, Level, False, False, True) =
             Scan.Value_From
               (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Value.Last) + 1,
                Openers, Level, False, False, True)
   is
   begin
      Bridge.Prefix_Context (Raw, Value.First - 1);
      if Model.Scan_State (Raw, Value.First - 1).Stack (3).Key = Tree_Key then
         Tree_Context (Model.Scan_State (Raw, Value.First - 1));
         Value_Mapping.Tree_Value (Raw, Value.First);
         Composition.Empty_Object_Skip
           (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Value.First), Openers, Level);
      else
         Value_Mapping.Retained_Value (Raw, Value.First);
         Value_Mapping.Retained_Skip (Raw, Value.First, Outer_Start, Openers, Level);
      end if;
   end Value_Projection;

   --  Keep the prefix arithmetic separate from the member traversal context.
   procedure Value_Position
     (Raw : Bytes.Sequence; Object, Value : Scan.Span)
     with Global => null,
       Pre => Ready (Raw, Object) and then Scan.Valid (Raw, Value)
         and then Object.First < Value.First and then Value.Last < Object.Last,
       Post => Mapping.First (Raw, Object.First) < Mapping.First (Raw, Value.First)
   is
   begin
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Containers.Container_Content (Raw, Object, Object_Container);
      Mapping.Interior_Position (Raw, Object.First, Value.First, Object.Last);
   end Value_Position;

   procedure Members_Continue
     (Raw : Bytes.Sequence; Object : Scan.Span; Position, Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Ready (Raw, Object)
         and then Bounds.Cursor_Ready (Raw, Object, Position, Object_Container)
         and then Model.Scan_State (Raw, Position - 1).Stack (3).Role = Check_Record
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Object.First)
         and then Level in 1 .. 3 and then Openers (Level) = '{',
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Object.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Object.Last)
         and then Relations.Record_Members
           (Raw, Object, Position, Mapping.Output (Raw),
            Mapping.Mapped (Raw, Object.First, Object.Last), Mapping.First (Raw, Position))
         and then Scan.Value_From
           (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Position),
            Openers, Level, False, False, True) =
             Scan.Value_From
               (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Object.Last),
                Openers, Level, False, False, True),
       Subprogram_Variant => (Decreases => Object.Last - Position)
   is
      M : constant Scan.Member := Scan.Member_Spec (Raw, Object, Position);
      Target : constant Bytes.Sequence := Mapping.Output (Raw);
      R : constant Scan.Span := Mapping.Mapped (Raw, Object.First, Object.Last);
   begin
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Containers.Container_Content (Raw, Object, Object_Container);
      Containers.Cursor_Content (Raw, Object, Position, Object_Container);
      Members.Member_Context (Raw, Object, Position);
      if M.State = Scan.Finished then
         Spans.Retained_Range (Raw, Position, Object.Last);
         Projected_Windows.Exact_Window (Raw, Position, Object.Last);
         Projected_Windows.Offset_Within (Raw, Position, Object.Last, Object.Last);
         Items.Finished_Space
           (Raw, Target, Object, R, Position, Projected_Windows.Shift (Raw, Position));
         Traversal.Spaces_Skip (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
      else
         Member_Mapping.Classify_Key (Raw, M.Key);
         Value_Position (Raw, Object, M.Value);
         Value_Projection (Raw, M.Value, Outer_Start, Openers, Level);
         Member_Mapping.Assemble_Present_Member (Raw, Object, Position);
         Traversal.Member_Head_Skip
           (Target, R, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.First (Raw, M.Value.First),
             Openers, Level, False, False, True));
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.Last (Raw, M.Value.Last) + 1,
             Openers, Level, False, False, True));
         Traversal.Member_Tail_Skip
           (Target, R, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.First (Raw, M.Next),
             Openers, Level, False, False, True));
         Members_Continue (Raw, Object, M.Next, Outer_Start, Openers, Level);
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.Last (Raw, Object.Last),
             Openers, Level, False, False, True));
      end if;
   end Members_Continue;

   procedure Record_Projection (Raw : Bytes.Sequence; Object : Scan.Span) is
      Openers : constant Scan.Nesting := Scan.Pushed (Scan.Empty_Nesting, 1, '{');
   begin
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Containers.Container_Content (Raw, Object, Object_Container);
      Members_Continue
        (Raw, Object, Object.First + 1, Mapping.First (Raw, Object.First), Openers, 1);
   end Record_Projection;

   procedure Record_Skip
     (Raw : Bytes.Sequence; Object : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
      Inside : constant Scan.Nesting := Scan.Pushed (Openers, Level + 1, '{');
   begin
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Containers.Container_Content (Raw, Object, Object_Container);
      Members_Continue (Raw, Object, Object.First + 1, Outer_Start, Inside, Level + 1);
      Composition.Prefix_Insensitive
        (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Object.Last) + 1,
         Inside, Openers, Level, False, False, True);
   end Record_Skip;
end Silver_Report_Projection_Records;
