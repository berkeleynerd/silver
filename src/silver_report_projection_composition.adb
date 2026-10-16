with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Lists;
with Silver_Report_Projection_Entry;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Roots;
with Silver_Report_Projection_Nonobjects;
with Silver_Report_Observation_Windows;
with Silver_Report_Projection_Members;
with Silver_Report_Projection_Keys;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Container_Mapping;
with Silver_Report_Projection_Member_Mapping;
with Silver_Report_Projection_Value_Mapping;
with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Items;
with Silver_Report_Observation_Traversal;
with Silver_Report_Observation_Composition;
package body Silver_Report_Projection_Composition with SPARK_Mode => On is
   package Lists renames Silver_Report_Projection_Lists;
   package Values renames Silver_Report_Projection_Values;
   package Roots renames Silver_Report_Projection_Roots;
   package Nonobjects renames Silver_Report_Projection_Nonobjects;
   package Windows renames Silver_Report_Observation_Windows;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Structure renames Silver_Report_Projection_Structure;
   package Members renames Silver_Report_Projection_Members;
   package Keys renames Silver_Report_Projection_Keys;
   package Spans renames Silver_Report_Projection_Spans;
   package Containers renames Silver_Report_Projection_Container_Mapping;
   package Member_Mapping renames Silver_Report_Projection_Member_Mapping;
   package Value_Mapping renames Silver_Report_Projection_Value_Mapping;
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Items renames Silver_Report_Observation_Items;
   package Traversal renames Silver_Report_Observation_Traversal;
   package Composition renames Silver_Report_Observation_Composition;
   use type Scan.Member_State;

   function Ready (Raw : Bytes.Sequence; Object : Scan.Span) return Boolean is
     (Bounds.Container_At (Raw, Object, Object_Container)
      and then Model.Scan_State (Raw, Object.First).Depth = 1
      and then Model.Scan_State (Raw, Object.First).Stack (1).Role = Root_Object);

   procedure Root_Value_Position (S : State)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Depth = 1 and then S.Stack (1).Role = Root_Object
         and then Structure.Awaits_Value (S.Stack (1)),
       Post => S.Stack (1).Position = Object_Value
   is
   begin
      pragma Assert (Structure.Frame_Valid (S, 1));
      pragma Assert (S.Stack (1).Container = Object_Container);
   end Root_Value_Position;

   procedure Value_Projection
     (Raw : Bytes.Sequence; Value : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting)
     with Global => null,
       Pre => Scan.Valid (Raw, Value) and then Values.Ready (Raw, Value.First)
         and then Value.Last = Scan.Value_Spec (Raw, Value.First)
         and then Value.Last < Bytes.Length (Raw)
         and then Model.Scan_State (Raw, Value.First - 1).Depth = 1
         and then Model.Scan_State (Raw, Value.First - 1).Stack (1).Role = Root_Object
         and then Spans.Retained (Raw, Value.Last + 1, Value.Last + 1)
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Value.First),
       Post =>
         (if Model.Scan_State (Raw, Value.First - 1).Stack (1).Key in Flow_Key | Proof_Key then
            Relations.Check_List (Raw, Value, Mapping.Output (Raw),
              Mapping.Mapped (Raw, Value.First, Value.Last))
          else Relations.Same_Content (Raw, Value, Mapping.Output (Raw),
              Mapping.Mapped (Raw, Value.First, Value.Last)))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Value.First)) =
           Mapping.Last (Raw, Value.Last)
         and then Scan.Value_From
           (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Value.First),
            Openers, 1, False, False, True) =
             Scan.Value_From
               (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Value.Last) + 1,
                Openers, 1, False, False, True)
   is
   begin
      Bridge.Prefix_Context (Raw, Value.First - 1);
      Root_Value_Position (Model.Scan_State (Raw, Value.First - 1));
      if Model.Scan_State (Raw, Value.First - 1).Stack (1).Key in Flow_Key | Proof_Key
        and then Bytes.Get (Raw, Value.First) = '[' then
         Silver_Report_Projection_Entry.Enter_Container (Raw, Value.First);
         Lists.List_Projection (Raw, Value);
         Lists.List_Skip (Raw, Value, Outer_Start, Openers);
      else
         Value_Mapping.Retained_Value (Raw, Value.First);
         Value_Mapping.Retained_Skip (Raw, Value.First, Outer_Start, Openers, 1);
         pragma Assert (Bytes.Get (Mapping.Output (Raw), Mapping.First (Raw, Value.First)) =
           Bytes.Get (Raw, Value.First));
         pragma Assert (Bytes.Get (Mapping.Output (Raw), Mapping.Last (Raw, Value.Last)) =
           Bytes.Get (Raw, Value.Last));
      end if;
   end Value_Projection;

   procedure Members_Continue
     (Raw : Bytes.Sequence; Object : Scan.Span; Position, Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Ready (Raw, Object)
         and then Bounds.Cursor_Ready (Raw, Object, Position, Object_Container)
         and then Model.Scan_State (Raw, Position - 1).Stack (1).Role = Root_Object
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Object.First)
         and then Level = 1 and then Openers (Level) = '{',
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Object.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Object.Last)
         and then Relations.Root_Members
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
         Mapping.Interior_Position (Raw, Object.First, M.Value.First, Object.Last);
         Value_Projection (Raw, M.Value, Outer_Start, Openers);
         Member_Mapping.Assemble_Present_Member (Raw, Object, Position);
         Traversal.Member_Head_Skip
           (Target, R, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
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

   procedure Root_Projection (Raw : Bytes.Sequence; Object : Scan.Span)
     with Global => null, Pre => Ready (Raw, Object),
       Post => Relations.Root_Objects
         (Raw, Object, Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Object.First)) =
           Mapping.Last (Raw, Object.Last)
   is
      Openers : constant Scan.Nesting := Scan.Pushed (Scan.Empty_Nesting, 1, '{');
   begin
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Containers.Container_Content (Raw, Object, Object_Container);
      Members_Continue
        (Raw, Object, Object.First + 1, Mapping.First (Raw, Object.First), Openers, 1);
   end Root_Projection;

   procedure Actual_Projection (Raw : Bytes.Sequence) is
      Start : constant Big_Natural := Scan.Space_End (Raw, 1);
   begin
      Roots.Root_Start (Raw);
      if Bytes.Get (Raw, Start) /= '{' then
         Nonobjects.Unchanged (Raw);
      else
         Bridge.Prefix_Context (Raw, Start);
         Silver_Report_Projection_Entry.Enter_Container (Raw, Start);
         Values.Value_Boundary (Raw, Start);
         Bridge.Container_End
           (Raw, Start, Start + 1, 0, Scan.Pushed (Scan.Empty_Nesting, 1, '{'), 1, False, False);
         declare
            Object : constant Scan.Span := (Start, Scan.Value_Spec (Raw, Start));
         begin
            Root_Projection (Raw, Object);
            Bridge.Prefix_Context (Raw, Object.Last);
            Roots.Suffix (Raw, Object.Last + 1);
            Roots.Projected_Suffix (Raw, Object.Last + 1);
            Containers.Container_Content (Raw, Object, Object_Container);
            pragma Assert (Spans.Retained (Raw, 1, Start));
            Spans.Retained_Range (Raw, 1, Start);
            Projected_Windows.Exact_Window (Raw, 1, Start);
            Projected_Windows.Offset_Within (Raw, 1, Start, Start);
            Windows.Space_End_Equivalent
              (Raw, Mapping.Output (Raw), 1, Start, 1, Projected_Windows.Shift (Raw, 1));
            pragma Assert (Scan.Space_End (Mapping.Output (Raw), 1) = Mapping.First (Raw, Start));
         end;
      end if;
   end Actual_Projection;
end Silver_Report_Projection_Composition;
