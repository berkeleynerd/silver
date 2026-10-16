package body Silver_Report_Observation_Assembly with SPARK_Mode => On is
   procedure Assemble_Member
     (Text : Bytes.Sequence; Object, Key, Value : Scan.Span;
      Position, Colon, Tail, Next : Offset)
     with Global => null,
       Pre => Scan.Valid (Text, Object) and then Scan.Valid (Text, Key)
         and then Scan.Valid (Text, Value)
         and then Position >= Object.First + 1 and then Position <= Key.First
         and then Key.Last < Colon and then Colon < Value.First
         and then Value.Last < Tail and then Tail <= Next and then Next <= Object.Last
         and then Scan.Space_End (Text, Position) = Key.First
         and then Bytes.Get (Text, Key.First) = '"'
         and then Scan.Value_Spec (Text, Key.First) = Key.Last
         and then Scan.Space_End (Text, Key.Last + 1) = Colon
         and then Bytes.Get (Text, Colon) = ':'
         and then Scan.Space_End (Text, Colon + 1) = Value.First
         and then Scan.Value_Spec (Text, Value.First) = Value.Last
         and then Scan.Space_End (Text, Value.Last + 1) = Tail
         and then (if Tail = Object.Last then Next = Tail else
           Bytes.Get (Text, Tail) = ','
           and then Scan.Space_End (Text, Tail + 1) = Next
           and then Next < Object.Last),
       Post => Scan.Member_Spec (Text, Object, Position) = (Scan.Present, Key, Value, Next)
   is
   begin
      null;
   end Assemble_Member;

   procedure Space_Edge
     (Left, Right : Bytes.Sequence; Position : Offset; Shift : Big_Integer)
   is
   begin
      if Scan.Space (Bytes.Get (Left, Position)) then
         Space_Edge (Left, Right, Position + 1, Shift);
      end if;
   end Space_Edge;

   procedure Member_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Before_Shift, After_Shift : Big_Integer)
   is
      M : constant Scan.Member := Scan.Member_Spec (Left, L, Position);
      C : constant Offset := Scan.Space_End (Left, M.Key.Last + 1);
      T : constant Offset := Scan.Space_End (Left, M.Value.Last + 1);
   begin
      Windows.Space_End_Window
        (Left, Right, Position, M.Value.First - 1, Position, Before_Shift);
      Windows.Value_Spec_Window
        (Left, Right, Position, M.Value.First - 1, M.Key.First, Before_Shift);
      Windows.Space_End_Window
        (Left, Right, Position, M.Value.First - 1, M.Key.Last + 1, Before_Shift);
      Space_Edge (Left, Right, C + 1, Before_Shift);
      Windows.Space_End_Window
        (Left, Right, M.Value.Last + 1, M.Next, M.Value.Last + 1, After_Shift);
      if T < L.Last then
         Windows.Space_End_Window
           (Left, Right, M.Value.Last + 1, M.Next, T + 1, After_Shift);
      end if;
      Assemble_Member
        (Right, R, (M.Key.First + Before_Shift, M.Key.Last + Before_Shift),
         (M.Value.First + Before_Shift, M.Value.Last + After_Shift),
         Position + Before_Shift, C + Before_Shift, T + After_Shift, M.Next + After_Shift);
   end Member_Transfer;
end Silver_Report_Observation_Assembly;
