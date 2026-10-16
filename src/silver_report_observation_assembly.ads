with SPARK.Big_Integers;
with Silver_Report_Observations;
with Silver_Report_Observation_Windows;

--  Reassemble byte-scanner members from unchanged punctuation and independently
--  established value endpoints. The value itself may have changed length.
package Silver_Report_Observation_Assembly
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Scan renames Silver_Report_Observations;
   package Windows renames Silver_Report_Observation_Windows;
   package Bytes renames Scan.Bytes;
   subtype Offset is Scan.Offset;
   use type Scan.Member_State;
   use type Scan.Member;

   procedure Space_Edge
     (Left, Right : Bytes.Sequence; Position : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Position >= 1 and then Position <= Bytes.Length (Left)
         and then Scan.Space_End (Left, Position) <= Bytes.Length (Left)
         and then Position + Shift >= 1
         and then Scan.Space_End (Left, Position) + Shift <= Bytes.Length (Right)
         and then not Scan.Space
           (Bytes.Get (Right, Scan.Space_End (Left, Position) + Shift))
         and then (if Position < Scan.Space_End (Left, Position) then
           Windows.Same_Window
             (Left, Right, Position, Scan.Space_End (Left, Position) - 1, Shift)),
       Post => Scan.Space_End (Right, Position + Shift) =
         Scan.Space_End (Left, Position) + Shift,
       Subprogram_Variant => (Decreases => Bytes.Length (Left) + 1 - Position);

   procedure Member_Transfer
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Position : Offset;
      Before_Shift, After_Shift : Big_Integer)
     with Global => null,
       Pre => Scan.Valid (Left, L) and then Scan.Valid (Right, R)
         and then Position >= L.First + 1
         and then Position <= Bytes.Length (Left) + 1
         and then Position + Before_Shift >= R.First + 1
         and then Position + Before_Shift <= Bytes.Length (Right) + 1
         and then
           (declare M : constant Scan.Member := Scan.Member_Spec (Left, L, Position);
            begin M.State = Scan.Present
              and then Windows.Same_Window
                (Left, Right, Position, M.Value.First - 1, Before_Shift)
              and then M.Value.First + Before_Shift <= M.Value.Last + After_Shift
              and then M.Value.Last + After_Shift < R.Last
              and then not Scan.Space (Bytes.Get (Right, M.Value.First + Before_Shift))
              and then Scan.Value_Spec (Right, M.Value.First + Before_Shift) =
                M.Value.Last + After_Shift
              and then Windows.Same_Window
                (Left, Right, M.Value.Last + 1, M.Next, After_Shift)
              and then M.Next + After_Shift <= R.Last
              and then (M.Next = L.Last) = (M.Next + After_Shift = R.Last)),
       Post =>
         (declare M : constant Scan.Member := Scan.Member_Spec (Left, L, Position);
          begin Scan.Member_Spec (Right, R, Position + Before_Shift) =
            (Scan.Present,
             (M.Key.First + Before_Shift, M.Key.Last + Before_Shift),
             (M.Value.First + Before_Shift, M.Value.Last + After_Shift),
             M.Next + After_Shift));
end Silver_Report_Observation_Assembly;
