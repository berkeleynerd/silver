with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Windows;
with Silver_Report_Observation_Assembly;
with Silver_Report_Observation_Composition;
with Silver_Report_Observation_Traversal;

package body Silver_Report_Projection_Item_Mapping with SPARK_Mode => On is
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Windows renames Silver_Report_Observation_Windows;
   package Assembly renames Silver_Report_Observation_Assembly;
   package Composition renames Silver_Report_Observation_Composition;
   package Traversal renames Silver_Report_Observation_Traversal;

   procedure Item_Identity
     (Text : Bytes.Sequence; Items : Scan.Span; Position : Offset)
   is
   begin
      null;
   end Item_Identity;

   procedure Assemble_Any_Item
     (Text : Bytes.Sequence; Items, Value : Scan.Span;
      Position, Tail, Next : Offset)
     with Global => null,
       Pre => Scan.Valid (Text, Items) and then Scan.Valid (Text, Value)
         and then Position >= Items.First + 1 and then Position <= Value.First
         and then Value.Last < Tail and then Tail <= Next and then Next <= Items.Last
         and then Scan.Space_End (Text, Position) = Value.First
         and then Scan.Value_Spec (Text, Value.First) = Value.Last
         and then Scan.Space_End (Text, Value.Last + 1) = Tail
         and then (if Tail = Items.Last then Next = Tail else
           Bytes.Get (Text, Tail) = ','
           and then Scan.Space_End (Text, Tail + 1) = Next
           and then Next < Items.Last),
       Post => Members.Any_Item_Spec (Text, Items, Position) =
         (Scan.Present, Scan.Missing, Value, Next)
   is
   begin
      null;
   end Assemble_Any_Item;

   procedure Assemble_Present_Item
     (Raw : Bytes.Sequence; Items : Scan.Span; Position : Offset)
   is
      M : constant Scan.Member := Members.Any_Item_Spec (Raw, Items, Position);
      T : constant Offset := Scan.Space_End (Raw, M.Value.Last + 1);
      Before_Shift : constant Big_Integer := Projected_Windows.Shift (Raw, Position);
      After_Shift : constant Big_Integer := Projected_Windows.Shift (Raw, M.Value.Last + 1);
   begin
      Item_Identity (Raw, Items, Position);
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, Items.First - 1), Bytes.Get (Raw, Items.First)).Length = 1);
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, Items.Last - 1), Bytes.Get (Raw, Items.Last)).Length = 1);
      Mapping.Nonempty_Range (Raw, Items.First, Items.Last);
      Mapping.Interior_Position (Raw, Items.First, Position, Items.Last);
      Mapping.Interior_End (Raw, M.Value.Last, Items.Last);

      Spans.Retained_Range (Raw, Position, M.Value.First - 1);
      if Position < M.Value.First then
         Projected_Windows.Exact_Window (Raw, Position, M.Value.First - 1);
      end if;
      Projected_Windows.Offset_Within (Raw, Position, M.Value.First - 1, M.Value.First);
      Spans.Retained_Range (Raw, M.Value.Last + 1, M.Next);
      Projected_Windows.Exact_Window (Raw, M.Value.Last + 1, M.Next);
      Projected_Windows.Offset_Within (Raw, M.Value.Last + 1, M.Next, M.Next);
      Mapping.Emission_At (Raw, M.Next);
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, M.Next - 1), Bytes.Get (Raw, M.Next)).Length = 1);
      pragma Assert (Mapping.First (Raw, M.Next) = Mapping.Last (Raw, M.Next));
      if M.Next < Items.Last then
         Mapping.Interior_End (Raw, M.Next, Items.Last);
      end if;
      pragma Assert ((M.Next = Items.Last) =
        (M.Next + After_Shift = Mapping.Last (Raw, Items.Last)));

      pragma Assert (not Scan.Space (Bytes.Get (Mapping.Output (Raw), Mapping.First (Raw, M.Value.First))));
      Assembly.Space_Edge (Raw, Mapping.Output (Raw), Position, Before_Shift);
      Windows.Space_End_Window
        (Raw, Mapping.Output (Raw), M.Value.Last + 1, M.Next, M.Value.Last + 1, After_Shift);
      if T < Items.Last then
         Windows.Space_End_Window
           (Raw, Mapping.Output (Raw), M.Value.Last + 1, M.Next, T + 1, After_Shift);
      end if;
      Assemble_Any_Item
        (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last),
         Mapping.Mapped (Raw, M.Value.First, M.Value.Last),
         Mapping.First (Raw, Position), T + After_Shift, Mapping.First (Raw, M.Next));
      pragma Assert (Members.Any_Item_Spec
        (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last),
         Mapping.First (Raw, Position)) =
          (Scan.Present, Scan.Missing, Mapping.Mapped (Raw, M.Value.First, M.Value.Last),
           Mapping.First (Raw, M.Next)));
      Item_Identity
        (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last),
         Mapping.First (Raw, Position));
   end Assemble_Present_Item;

   procedure Item_Head_Skip
     (Text : Bytes.Sequence; Items : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
   begin
      Item_Identity (Text, Items, Position);
      Traversal.Spaces_Skip (Text, Start, Position, Openers, Level);
   end Item_Head_Skip;

   procedure Item_Tail_Skip
     (Text : Bytes.Sequence; Items : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
      M : constant Scan.Member := Members.Any_Item_Spec (Text, Items, Position);
      T : constant Offset := Scan.Space_End (Text, M.Value.Last + 1);
   begin
      Item_Identity (Text, Items, Position);
      Traversal.Spaces_Skip (Text, Start, M.Value.Last + 1, Openers, Level);
      if T < Items.Last then
         Composition.Plain_Skip (Text, Start, T, T + 1, Openers, Level);
         Traversal.Spaces_Skip (Text, Start, T + 1, Openers, Level);
      end if;
   end Item_Tail_Skip;
end Silver_Report_Projection_Item_Mapping;
