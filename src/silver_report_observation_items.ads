with SPARK.Big_Integers;
with Silver_Report_Observations;
with Silver_Report_Observation_Windows;

--  Reassemble array-item observations after independently established value
--  projection. Head and separator bytes retain their original observations.
package Silver_Report_Observation_Items
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Scan renames Silver_Report_Observations;
   package Windows renames Silver_Report_Observation_Windows;
   package Bytes renames Scan.Bytes;
   subtype Offset is Scan.Offset;
   use type Scan.Member_State;
   use type Scan.Member;

   procedure Item_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Before_Shift, After_Shift : Big_Integer)
     with Global => null,
       Pre => Scan.Valid (Left, L) and then Scan.Valid (Right, R)
         and then Position >= L.First + 1
         and then Position <= Bytes.Length (Left) + 1
         and then Position + Before_Shift >= R.First + 1
         and then Position + Before_Shift <= Bytes.Length (Right) + 1
         and then
           (declare M : constant Scan.Member := Scan.Item_Spec (Left, L, Position);
            begin M.State = Scan.Present
              and then (if Position < M.Value.First then Windows.Same_Window
                (Left, Right, Position, M.Value.First - 1, Before_Shift))
              and then M.Value.First + Before_Shift <= M.Value.Last + After_Shift
              and then M.Value.Last + After_Shift < R.Last
              and then Bytes.Get (Right, M.Value.First + Before_Shift) = '{'
              and then Scan.Value_Spec (Right, M.Value.First + Before_Shift) =
                M.Value.Last + After_Shift
              and then Windows.Same_Window
                (Left, Right, M.Value.Last + 1, M.Next, After_Shift)
              and then M.Next + After_Shift <= R.Last
              and then (M.Next = L.Last) = (M.Next + After_Shift = R.Last)),
       Post =>
         (declare M : constant Scan.Member := Scan.Item_Spec (Left, L, Position);
          begin Scan.Item_Spec (Right, R, Position + Before_Shift) =
            (Scan.Present, Scan.Missing,
             (M.Value.First + Before_Shift, M.Value.Last + After_Shift),
             M.Next + After_Shift));

   procedure Finished_Space
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Shift : Big_Integer)
     with Global => null,
       Pre => Scan.Valid (Left, L) and then Scan.Valid (Right, R)
         and then Position >= L.First + 1 and then Position <= L.Last
         and then Position + Shift >= R.First + 1
         and then L.Last + Shift = R.Last
         and then Scan.Space_End (Left, Position) = L.Last
         and then not Scan.Space (Bytes.Get (Right, R.Last))
         and then (if Position < L.Last then Windows.Same_Window
           (Left, Right, Position, L.Last - 1, Shift)),
       Post => Scan.Space_End (Right, Position + Shift) = R.Last
         and then Scan.Item_Spec (Right, R, Position + Shift) = Scan.End_Member
         and then Scan.Member_Spec (Right, R, Position + Shift) = Scan.End_Member;

   --  Complete original JSON arrays cannot have malformed value or separator
   --  bytes. Their remaining Broken observation is a nonobject item head.
   procedure Broken_Head_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Shift : Big_Integer)
     with Global => null,
       Pre => Scan.Valid (Left, L) and then Scan.Valid (Right, R)
         and then Position >= L.First + 1
         and then Position <= Bytes.Length (Left) + 1
         and then Position + Shift >= R.First + 1
         and then Position + Shift <= Bytes.Length (Right) + 1
         and then
           (declare P : constant Offset := Scan.Space_End (Left, Position);
            begin P < L.Last and then P + Shift < R.Last
              and then Bytes.Get (Left, P) /= '{'
              and then Windows.Same_Window (Left, Right, Position, P, Shift)),
       Post => Scan.Item_Spec (Left, L, Position) = Scan.Bad_Member
         and then Scan.Item_Spec (Right, R, Position + Shift) = Scan.Bad_Member;
end Silver_Report_Observation_Items;
