with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Entry;
with Silver_Report_Projection_Members;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Container_Mapping;
with Silver_Report_Projection_Item_Mapping;
with Silver_Report_Projection_Value_Mapping;
with Silver_Report_Projection_Records;
with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Items;
with Silver_Report_Observation_Traversal;
with Silver_Report_Observation_Composition;
package body Silver_Report_Projection_Lists with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Members renames Silver_Report_Projection_Members;
   package Spans renames Silver_Report_Projection_Spans;
   package Containers renames Silver_Report_Projection_Container_Mapping;
   package Item_Mapping renames Silver_Report_Projection_Item_Mapping;
   package Value_Mapping renames Silver_Report_Projection_Value_Mapping;
   package Records renames Silver_Report_Projection_Records;
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Observation_Items renames Silver_Report_Observation_Items;
   package Traversal renames Silver_Report_Observation_Traversal;
   package Composition renames Silver_Report_Observation_Composition;
   use type Scan.Member_State;

   procedure Items_Continue
     (Raw : Bytes.Sequence; Items : Scan.Span; Position, Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Ready (Raw, Items)
         and then Bounds.Cursor_Ready (Raw, Items, Position, Array_Container)
         and then Model.Scan_State (Raw, Position - 1).Stack (2).Role = Check_List
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Items.First)
         and then Level in 1 .. 2 and then Openers (Level) = '[',
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Items.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Items.Last)
         and then Relations.List_Items
           (Raw, Items, Position, Mapping.Output (Raw),
            Mapping.Mapped (Raw, Items.First, Items.Last), Mapping.First (Raw, Position))
         and then Scan.Value_From
           (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Position),
            Openers, Level, False, False, True) =
             Scan.Value_From
               (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Items.Last),
                Openers, Level, False, False, True),
       Subprogram_Variant => (Decreases => Items.Last - Position)
   is
      M : constant Scan.Member := Members.Any_Item_Spec (Raw, Items, Position);
      Target : constant Bytes.Sequence := Mapping.Output (Raw);
      R : constant Scan.Span := Mapping.Mapped (Raw, Items.First, Items.Last);
   begin
      Bounds.Container_Boundary (Raw, Items, Array_Container);
      Containers.Container_Content (Raw, Items, Array_Container);
      Containers.Cursor_Content (Raw, Items, Position, Array_Container);
      Members.Any_Item_Context (Raw, Items, Position);
      Item_Mapping.Item_Identity (Raw, Items, Position);
      if M.State = Scan.Finished then
         Spans.Retained_Range (Raw, Position, Items.Last);
         Projected_Windows.Exact_Window (Raw, Position, Items.Last);
         Projected_Windows.Offset_Within (Raw, Position, Items.Last, Items.Last);
         Observation_Items.Finished_Space
           (Raw, Target, Items, R, Position, Projected_Windows.Shift (Raw, Position));
         Traversal.Spaces_Skip (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
      else
         Bridge.Prefix_Context (Raw, M.Value.First - 1);
         Bridge.Prefix_Context (Raw, M.Value.First);
         if Bytes.Get (Raw, M.Value.First) = '{' then
            Silver_Report_Projection_Entry.Enter_Container (Raw, M.Value.First);
            Records.Record_Projection (Raw, M.Value);
         else
            Value_Mapping.Retained_Value (Raw, M.Value.First);
         end if;
         Item_Mapping.Assemble_Present_Item (Raw, Items, Position);
         Item_Mapping.Item_Head_Skip
           (Target, R, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
         if Bytes.Get (Raw, M.Value.First) = '{' then
            Records.Record_Skip (Raw, M.Value, Outer_Start, Openers, Level);
         else
            Value_Mapping.Retained_Skip (Raw, M.Value.First, Outer_Start, Openers, Level);
         end if;
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.Last (Raw, M.Value.Last) + 1,
             Openers, Level, False, False, True));
         Item_Mapping.Item_Tail_Skip
           (Target, R, Outer_Start, Mapping.First (Raw, Position), Openers, Level);
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.First (Raw, M.Next),
             Openers, Level, False, False, True));
         Items_Continue (Raw, Items, M.Next, Outer_Start, Openers, Level);
         pragma Assert (Scan.Value_From
           (Target, Outer_Start, Mapping.First (Raw, Position), Openers, Level, False, False, True) =
           Scan.Value_From (Target, Outer_Start, Mapping.Last (Raw, Items.Last),
             Openers, Level, False, False, True));
      end if;
   end Items_Continue;

   procedure List_Projection (Raw : Bytes.Sequence; Items : Scan.Span) is
      Openers : constant Scan.Nesting := Scan.Pushed (Scan.Empty_Nesting, 1, '[');
   begin
      Bounds.Container_Boundary (Raw, Items, Array_Container);
      Containers.Container_Content (Raw, Items, Array_Container);
      Items_Continue
        (Raw, Items, Items.First + 1, Mapping.First (Raw, Items.First), Openers, 1);
   end List_Projection;

   procedure List_Skip
     (Raw : Bytes.Sequence; Items : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting)
   is
      Inside : constant Scan.Nesting := Scan.Pushed (Openers, 2, '[');
   begin
      Bounds.Container_Boundary (Raw, Items, Array_Container);
      Containers.Container_Content (Raw, Items, Array_Container);
      Items_Continue (Raw, Items, Items.First + 1, Outer_Start, Inside, 2);
      Composition.Prefix_Insensitive
        (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Items.Last) + 1,
         Inside, Openers, 1, False, False, True);
   end List_Skip;
end Silver_Report_Projection_Lists;
