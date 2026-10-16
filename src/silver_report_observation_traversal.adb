with Silver_Report_Observation_Composition;
package body Silver_Report_Observation_Traversal with SPARK_Mode => On is
   package Composition renames Silver_Report_Observation_Composition;

   procedure Spaces_Skip
     (Text : Bytes.Sequence; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
   begin
      if Position <= Bytes.Length (Text) and then Scan.Space (Bytes.Get (Text, Position)) then
         Spaces_Skip (Text, Start, Position + 1, Openers, Level);
      end if;
   end Spaces_Skip;

   procedure Member_Head_Skip
     (Text : Bytes.Sequence; Object : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
      M : constant Scan.Member := Scan.Member_Spec (Text, Object, Position);
      C : constant Offset := Scan.Space_End (Text, M.Key.Last + 1);
   begin
      Spaces_Skip (Text, Start, Position, Openers, Level);
      Composition.Quoted_Skip (Text, Start, M.Key.First, M.Key.Last, Openers, Level);
      Spaces_Skip (Text, Start, M.Key.Last + 1, Openers, Level);
      Composition.Plain_Skip (Text, Start, C, C + 1, Openers, Level);
      Spaces_Skip (Text, Start, C + 1, Openers, Level);
   end Member_Head_Skip;

   procedure Member_Tail_Skip
     (Text : Bytes.Sequence; Object : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
      M : constant Scan.Member := Scan.Member_Spec (Text, Object, Position);
      T : constant Offset := Scan.Space_End (Text, M.Value.Last + 1);
   begin
      Spaces_Skip (Text, Start, M.Value.Last + 1, Openers, Level);
      if T < Object.Last then
         Composition.Plain_Skip (Text, Start, T, T + 1, Openers, Level);
         Spaces_Skip (Text, Start, T + 1, Openers, Level);
      end if;
   end Member_Tail_Skip;
end Silver_Report_Observation_Traversal;
