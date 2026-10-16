with SPARK.Big_Integers;
with Silver_Report_Observations;

--  Compositional scanner equalities retain an arbitrary following suffix.
--  They therefore do not assume that the projected report is accepted.
package Silver_Report_Observation_Composition
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Observations.Bytes;
   subtype Offset is Observations.Offset;

   function Same_Prefix
     (Left, Right : Observations.Nesting; Level : Observations.Nesting_Level)
      return Boolean is
     (for all I in 1 .. Level => Left (I) = Right (I));

   procedure Prefix_Insensitive
     (Text : Bytes.Sequence; Start, Position : Offset;
      Left, Right : Observations.Nesting; Level : Observations.Nesting_Level;
      Quoted, Escaped, Container : Boolean)
     with Global => null,
       Pre => Start >= 1 and then Start <= Position
         and then Position <= Bytes.Length (Text) + 1
         and then Same_Prefix (Left, Right, Level),
       Post => Observations.Value_From
         (Text, Start, Position, Left, Level, Quoted, Escaped, Container) =
           Observations.Value_From
         (Text, Start, Position, Right, Level, Quoted, Escaped, Container),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);

   procedure Container_Closes
     (Text : Bytes.Sequence; Start, Position : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level;
      Quoted, Escaped : Boolean)
     with Global => null,
       Pre => Start >= 1 and then Start <= Position
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0,
       Post => (if Observations.Value_From
         (Text, Start, Position, Openers, Level, Quoted, Escaped, True) > 0 then
           (if Openers (1) = '{' then
              Bytes.Get (Text, Observations.Value_From
                (Text, Start, Position, Openers, Level, Quoted, Escaped, True)) = '}'
            elsif Openers (1) = '[' then
              Bytes.Get (Text, Observations.Value_From
                (Text, Start, Position, Openers, Level, Quoted, Escaped, True)) = ']'
            else False)),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);

   procedure Plain_Skip
     (Text : Bytes.Sequence; Start, First, After : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
     with Global => null,
       Pre => Start >= 1 and then Start <= First and then First <= After
         and then After <= Bytes.Length (Text) + 1 and then Level > 0
         and then (for all I in Text =>
           (if First <= I and then I < After then
             Bytes.Get (Text, I) not in '"' | '{' | '[' | '}' | ']')),
       Post => Observations.Value_From
         (Text, Start, First, Openers, Level, False, False, True) =
           Observations.Value_From
         (Text, Start, After, Openers, Level, False, False, True),
       Subprogram_Variant => (Decreases => After - First);

   procedure Quoted_Skip
     (Text : Bytes.Sequence; Start, First, Last : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
     with Global => null,
       Pre => Start >= 1 and then Start <= First
         and then First <= Bytes.Length (Text)
         and then Bytes.Get (Text, First) = '"'
         and then Last > 0 and then Observations.Value_Spec (Text, First) = Last
         and then Level > 0,
       Post => Observations.Value_From
         (Text, Start, First, Openers, Level, False, False, True) =
           Observations.Value_From
         (Text, Start, Last + 1, Openers, Level, False, False, True);

   procedure Empty_Object_Skip
     (Text : Bytes.Sequence; Start, First : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
     with Global => null,
       Pre => Start >= 1 and then Start <= First
         and then First + 1 <= Bytes.Length (Text)
         and then Bytes.Get (Text, First) = '{'
         and then Bytes.Get (Text, First + 1) = '}'
         and then Level > 0 and then Level < 64,
       Post => Observations.Value_From
         (Text, Start, First, Openers, Level, False, False, True) =
           Observations.Value_From
         (Text, Start, First + 2, Openers, Level, False, False, True);
end Silver_Report_Observation_Composition;
