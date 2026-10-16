with Silver_Report_Observation_Assembly;

package body Silver_Report_Observation_Items with SPARK_Mode => On is
   package Assembly renames Silver_Report_Observation_Assembly;

   procedure Assemble_Item
     (Text : Bytes.Sequence; Items, Value : Scan.Span;
      Position, Tail, Next : Offset)
     with Global => null,
       Pre => Scan.Valid (Text, Items) and then Scan.Valid (Text, Value)
         and then Position >= Items.First + 1 and then Position <= Value.First
         and then Value.Last < Tail and then Tail <= Next and then Next <= Items.Last
         and then Scan.Space_End (Text, Position) = Value.First
         and then Bytes.Get (Text, Value.First) = '{'
         and then Scan.Value_Spec (Text, Value.First) = Value.Last
         and then Scan.Space_End (Text, Value.Last + 1) = Tail
         and then (if Tail = Items.Last then Next = Tail else
           Bytes.Get (Text, Tail) = ','
           and then Scan.Space_End (Text, Tail + 1) = Next
           and then Next < Items.Last),
       Post => Scan.Item_Spec (Text, Items, Position) =
         (Scan.Present, Scan.Missing, Value, Next)
   is
   begin
      null;
   end Assemble_Item;

   procedure Item_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Before_Shift, After_Shift : Big_Integer)
   is
      M : constant Scan.Member := Scan.Item_Spec (Left, L, Position);
      T : constant Offset := Scan.Space_End (Left, M.Value.Last + 1);
   begin
      Assembly.Space_Edge (Left, Right, Position, Before_Shift);
      Windows.Space_End_Window
        (Left, Right, M.Value.Last + 1, M.Next, M.Value.Last + 1, After_Shift);
      if T < L.Last then
         Windows.Space_End_Window
           (Left, Right, M.Value.Last + 1, M.Next, T + 1, After_Shift);
      end if;
      Assemble_Item
        (Right, R, (M.Value.First + Before_Shift, M.Value.Last + After_Shift),
         Position + Before_Shift, T + After_Shift, M.Next + After_Shift);
   end Item_Transfer;

   procedure Finished_Space
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Shift : Big_Integer)
   is
   begin
      Assembly.Space_Edge (Left, Right, Position, Shift);
   end Finished_Space;

   procedure Broken_Head_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Shift : Big_Integer)
   is
      P : constant Offset := Scan.Space_End (Left, Position);
   begin
      Windows.Space_End_Window (Left, Right, Position, P, Position, Shift);
   end Broken_Head_Transfer;
end Silver_Report_Observation_Items;
