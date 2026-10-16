with SPARK.Big_Integers;
with Silver_Report_Observations;

--  Byte-window correspondence is independent of the projection and of report
--  acceptance. Prefix termination preserves both successful observations and
--  the auditor's malformed/beyond-container outcomes under an offset change.
package Silver_Report_Observation_Windows
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Observations.Bytes;
   subtype Offset is Observations.Offset;
   use type Observations.Member_State;
   use type Observations.Span;

   function Same_Window
     (Left, Right : Bytes.Sequence; First, Last : Offset; Shift : Big_Integer)
      return Boolean is
     (Observations.Valid (Left, (First, Last))
      and then First + Shift >= 1 and then Last + Shift <= Bytes.Length (Right)
      and then (for all P in Left =>
        (if P >= First and then P <= Last then
          Bytes.Get (Left, P) = Bytes.Get (Right, P + Shift)))
      and then (for all P in Right =>
        (if P >= First + Shift and then P <= Last + Shift then
          Bytes.Get (Left, P - Shift) = Bytes.Get (Right, P))));

   function Shifted_Span
     (Left, Right : Observations.Span; Shift : Big_Integer) return Boolean is
     (if Left.First = 0 then Right = Left
      else Right.First = Left.First + Shift and then Right.Last = Left.Last + Shift);

   function Shifted_Member
     (Left, Right : Observations.Member; Shift : Big_Integer) return Boolean is
     (Left.State = Right.State
      and then Shifted_Span (Left.Key, Right.Key, Shift)
      and then Shifted_Span (Left.Value, Right.Value, Shift)
      and then (if Left.Next = 0 then Right.Next = 0 else Right.Next = Left.Next + Shift));

   procedure Reverse_Window
     (Left, Right : Bytes.Sequence; First, Last : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift),
       Post => Same_Window (Right, Left, First + Shift, Last + Shift, -Shift);

   procedure Space_End_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Position >= First and then Position <= Last + 1
         and then Observations.Space_End (Left, Position) <= Last,
       Post => Observations.Space_End (Right, Position + Shift) =
         Observations.Space_End (Left, Position) + Shift,
       Subprogram_Variant => (Decreases => Last + 1 - Position);

   procedure Space_End_Equivalent
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Position >= First and then Position <= Last + 1,
       Post => (Observations.Space_End (Left, Position) <= Last) =
           (Observations.Space_End (Right, Position + Shift) <= Last + Shift)
         and then (if Observations.Space_End (Left, Position) <= Last then
           Observations.Space_End (Right, Position + Shift) =
             Observations.Space_End (Left, Position) + Shift);

   procedure Value_From_Progress
     (Text : Bytes.Sequence; Start, Position : Offset; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped, Container : Boolean)
     with Global => null,
       Pre => Start >= 1 and then Start <= Bytes.Length (Text) + 1
         and then Position >= Start and then Position <= Bytes.Length (Text) + 1,
       Post => Observations.Value_From
           (Text, Start, Position, Openers, Level, Quoted, Escaped, Container) = 0
         or else (if Quoted or else Container then Observations.Value_From
           (Text, Start, Position, Openers, Level, Quoted, Escaped, Container) >= Position
         else Observations.Value_From
           (Text, Start, Position, Openers, Level, Quoted, Escaped, Container) + 1 >= Position),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);

   procedure Value_From_Window
     (Left, Right : Bytes.Sequence; First, Last, Start, Position : Offset;
      Shift : Big_Integer; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped, Container : Boolean)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Start >= First and then Start <= Last + 1
         and then Position >= Start and then Position <= Last + 1
         and then Observations.Value_From
           (Left, Start, Position, Openers, Level, Quoted, Escaped, Container) > 0
         and then (Observations.Value_From
           (Left, Start, Position, Openers, Level, Quoted, Escaped, Container) < Last
           or else ((Quoted or else Container) and then Observations.Value_From
             (Left, Start, Position, Openers, Level, Quoted, Escaped, Container) = Last)),
       Post => Observations.Value_From
           (Right, Start + Shift, Position + Shift, Openers, Level, Quoted, Escaped, Container) =
         Observations.Value_From
           (Left, Start, Position, Openers, Level, Quoted, Escaped, Container) + Shift,
       Subprogram_Variant => (Decreases => Last + 1 - Position);

   procedure Value_Spec_Window
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Start >= First and then Start <= Last + 1
         and then Observations.Value_Spec (Left, Start) > 0
         and then Observations.Value_Spec (Left, Start) < Last,
       Post => Observations.Value_Spec (Right, Start + Shift) =
         Observations.Value_Spec (Left, Start) + Shift;

   --  Quotes and containers consume their final byte; primitive termination
   --  needs the following delimiter and uses Value_Spec_Window instead.
   procedure Closed_Value_Window
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Start >= First and then Start <= Last
         and then Bytes.Get (Left, Start) in '"' | '{' | '['
         and then Observations.Value_Spec (Left, Start) > 0
         and then Observations.Value_Spec (Left, Start) <= Last,
       Post => Observations.Value_Spec (Right, Start + Shift) =
         Observations.Value_Spec (Left, Start) + Shift;

   procedure Value_Spec_Equivalent
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Start >= First and then Start <= Last + 1,
       Post => (Observations.Value_Spec (Left, Start) > 0
           and then Observations.Value_Spec (Left, Start) < Last) =
         (Observations.Value_Spec (Right, Start + Shift) > 0
           and then Observations.Value_Spec (Right, Start + Shift) < Last + Shift)
         and then (if Observations.Value_Spec (Left, Start) > 0
           and then Observations.Value_Spec (Left, Start) < Last then
             Observations.Value_Spec (Right, Start + Shift) =
               Observations.Value_Spec (Left, Start) + Shift);

   procedure Member_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Position >= First + 1 and then Position <= Last + 1,
       Post => Shifted_Member
         (Observations.Member_Spec (Left, (First, Last), Position),
          Observations.Member_Spec (Right, (First + Shift, Last + Shift), Position + Shift), Shift);

   procedure Item_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
     with Global => null,
       Pre => Same_Window (Left, Right, First, Last, Shift)
         and then Position >= First + 1 and then Position <= Last + 1,
       Post => Shifted_Member
         (Observations.Item_Spec (Left, (First, Last), Position),
          Observations.Item_Spec (Right, (First + Shift, Last + Shift), Position + Shift), Shift);
end Silver_Report_Observation_Windows;
