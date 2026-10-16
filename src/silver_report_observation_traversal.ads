with SPARK.Big_Integers;
with Silver_Report_Observations;

--  Skip the punctuation of observed members in an enclosing value scanner.
--  These equations require no accepted-report or enclosing endpoint premise.
package Silver_Report_Observation_Traversal
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Scan.Bytes;
   subtype Offset is Scan.Offset;
   use type Scan.Member_State;

   procedure Spaces_Skip
     (Text : Bytes.Sequence; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Start >= 1 and then Start <= Position
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0,
       Post => Scan.Value_From (Text, Start, Position, Openers, Level, False, False, True) =
         Scan.Value_From
           (Text, Start, Scan.Space_End (Text, Position), Openers, Level, False, False, True),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);

   procedure Member_Head_Skip
     (Text : Bytes.Sequence; Object : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Scan.Valid (Text, Object) and then Start >= 1
         and then Start <= Position and then Position >= Object.First + 1
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0
         and then Scan.Member_Spec (Text, Object, Position).State = Scan.Present,
       Post => Scan.Value_From (Text, Start, Position, Openers, Level, False, False, True) =
         Scan.Value_From
           (Text, Start, Scan.Member_Spec (Text, Object, Position).Value.First,
            Openers, Level, False, False, True);

   procedure Member_Tail_Skip
     (Text : Bytes.Sequence; Object : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Scan.Valid (Text, Object) and then Start >= 1
         and then Start <= Position and then Position >= Object.First + 1
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0
         and then Scan.Member_Spec (Text, Object, Position).State = Scan.Present,
       Post => Scan.Value_From
         (Text, Start, Scan.Member_Spec (Text, Object, Position).Value.Last + 1,
          Openers, Level, False, False, True) =
           Scan.Value_From
             (Text, Start, Scan.Member_Spec (Text, Object, Position).Next,
              Openers, Level, False, False, True);
end Silver_Report_Observation_Traversal;
