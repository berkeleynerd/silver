with SPARK.Big_Integers;
with Silver_Report_Projection_Model;

--  The auditor's byte-derived structural observations, with mathematical
--  positions rather than a report-storage bound. These equations deliberately
--  retain the auditor's byte scanner, including its malformed/missing outcomes;
--  they do not define meaning by running the projection or accepting its output.
package Silver_Report_Observations
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Bytes renames Silver_Report_Projection_Model.Byte_Sequences;
   subtype Offset is Big_Natural;
   type Span is record
      First : Offset := 0;
      Last : Offset := 0;
   end record;
   Missing : constant Span := (0, 0);
   Malformed : constant Span := (0, 1);

   function Valid (Text : Bytes.Sequence; Item : Span) return Boolean is
     (Item.First >= 1 and then Item.First <= Item.Last
      and then Item.Last <= Bytes.Length (Text));
   function Space (C : Character) return Boolean is
     (C = ' ' or else C = Character'Val (9)
      or else C = Character'Val (10) or else C = Character'Val (13));

   function Space_End (Text : Bytes.Sequence; Position : Offset) return Offset
     with Global => null,
       Pre => Position >= 1 and then Position <= Bytes.Length (Text) + 1,
       Post => Space_End'Result >= Position
         and then Space_End'Result <= Bytes.Length (Text) + 1,
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);
   function Space_End (Text : Bytes.Sequence; Position : Offset) return Offset is
     (if Position > Bytes.Length (Text) or else not Space (Bytes.Get (Text, Position))
      then Position else Space_End (Text, Position + 1));

   type Nesting is array (Positive range 1 .. 64) of Character;
   Empty_Nesting : constant Nesting := (others => ' ');
   subtype Nesting_Level is Natural range 0 .. 64;
   function Pushed (Stack : Nesting; Level : Positive; C : Character) return Nesting is
     ((Stack with delta Level => C))
     with Pre => Level <= 64;

   function Value_From
     (Text : Bytes.Sequence; Start, Position : Offset; Openers : Nesting;
      Level : Nesting_Level; Quoted, Escaped, Container : Boolean) return Offset
     with Global => null,
       Pre => Start >= 1 and then Start <= Bytes.Length (Text) + 1
         and then Position >= Start and then Position <= Bytes.Length (Text) + 1,
       Post => Value_From'Result = 0 or else
         (Value_From'Result >= Start and then Value_From'Result <= Bytes.Length (Text)),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position);
   function Value_From
     (Text : Bytes.Sequence; Start, Position : Offset; Openers : Nesting;
      Level : Nesting_Level; Quoted, Escaped, Container : Boolean) return Offset is
     (if Position > Bytes.Length (Text) then 0
      elsif Quoted then
        (if Escaped then
           Value_From (Text, Start, Position + 1, Openers, Level, True, False, Container)
         elsif Bytes.Get (Text, Position) = '\' then
           Value_From (Text, Start, Position + 1, Openers, Level, True, True, Container)
         elsif Bytes.Get (Text, Position) = '"' then
           (if not Container then Position
            else Value_From (Text, Start, Position + 1, Openers, Level, False, False, Container))
         else Value_From (Text, Start, Position + 1, Openers, Level, True, False, Container))
      elsif Bytes.Get (Text, Position) = '"' then
        Value_From (Text, Start, Position + 1, Openers, Level, True, Escaped, Container)
      elsif Bytes.Get (Text, Position) = '{' or else Bytes.Get (Text, Position) = '[' then
        (if Level = 64 then 0
         else Value_From (Text, Start, Position + 1,
                          Pushed (Openers, Level + 1, Bytes.Get (Text, Position)),
                          Level + 1, False, Escaped, Container))
      elsif Bytes.Get (Text, Position) = '}' or else Bytes.Get (Text, Position) = ']' then
        (if Level = 0 then
           (if Position > Start and then not Container then Position - 1 else 0)
         elsif (Bytes.Get (Text, Position) = '}' and then Openers (Level) /= '{')
           or else (Bytes.Get (Text, Position) = ']' and then Openers (Level) /= '[')
         then 0
         elsif Level = 1 then Position
         else Value_From (Text, Start, Position + 1, Openers, Level - 1,
                          False, Escaped, Container))
      elsif not Container and then
        (Bytes.Get (Text, Position) = ',' or else Space (Bytes.Get (Text, Position)))
      then (if Position > Start then Position - 1 else 0)
      else Value_From (Text, Start, Position + 1, Openers, Level, False, Escaped, Container));

   function Value_Spec (Text : Bytes.Sequence; Start : Offset) return Offset
     with Global => null,
       Pre => Start >= 1 and then Start <= Bytes.Length (Text) + 1,
       Post => Value_Spec'Result = 0 or else
         (Value_Spec'Result >= Start and then Value_Spec'Result <= Bytes.Length (Text));
   function Value_Spec (Text : Bytes.Sequence; Start : Offset) return Offset is
     (Value_From (Text, Start, Start, Empty_Nesting, 0, False, False,
       Start <= Bytes.Length (Text)
         and then (Bytes.Get (Text, Start) = '{' or else Bytes.Get (Text, Start) = '[')));

   type Member_State is (Broken, Finished, Present);
   type Member is record
      State : Member_State := Broken;
      Key : Span := Missing;
      Value : Span := Missing;
      Next : Offset := 0;
   end record;
   Bad_Member : constant Member := (Broken, Missing, Missing, 0);
   End_Member : constant Member := (Finished, Missing, Missing, 0);

   function Member_Spec (Text : Bytes.Sequence; Object : Span; Position : Offset)
     return Member
     with Global => null,
       Pre => Valid (Text, Object)
         and then Position >= Object.First + 1
         and then Position <= Bytes.Length (Text) + 1,
       Post => (if Member_Spec'Result.State = Present then
         Valid (Text, Member_Spec'Result.Key)
         and then Valid (Text, Member_Spec'Result.Value)
         and then Member_Spec'Result.Next >= Position + 1
         and then Member_Spec'Result.Next <= Object.Last);
   function Member_Spec (Text : Bytes.Sequence; Object : Span; Position : Offset)
     return Member is
     (declare P : constant Offset := Space_End (Text, Position);
      begin
        (if P = Object.Last then End_Member
         elsif P >= Object.Last or else Bytes.Get (Text, P) /= '"' then Bad_Member
         else
           (declare K : constant Offset := Value_Spec (Text, P);
            begin
              (if K = 0 or else K >= Object.Last then Bad_Member
               else
                 (declare C : constant Offset := Space_End (Text, K + 1);
                  begin
                    (if C >= Object.Last or else Bytes.Get (Text, C) /= ':' then Bad_Member
                     else
                       (declare V : constant Offset := Space_End (Text, C + 1);
                                L : constant Offset := Value_Spec (Text, V);
                        begin
                          (if L = 0 or else L >= Object.Last then Bad_Member
                           else
                             (declare T : constant Offset := Space_End (Text, L + 1);
                              begin
                                (if T = Object.Last then (Present, (P, K), (V, L), T)
                                 elsif T >= Object.Last or else Bytes.Get (Text, T) /= ',' then Bad_Member
                                 else
                                   (declare N : constant Offset := Space_End (Text, T + 1);
                                    begin
                                      (if N >= Object.Last then Bad_Member
                                       else (Present, (P, K), (V, L), N)))))))))))));

   function Item_Spec (Text : Bytes.Sequence; Items : Span; Position : Offset)
     return Member
     with Global => null,
       Pre => Valid (Text, Items)
         and then Position >= Items.First + 1
         and then Position <= Bytes.Length (Text) + 1,
       Post => (if Item_Spec'Result.State = Present then
         Valid (Text, Item_Spec'Result.Value)
         and then Item_Spec'Result.Next >= Position + 1
         and then Item_Spec'Result.Next <= Items.Last);
   function Item_Spec (Text : Bytes.Sequence; Items : Span; Position : Offset)
     return Member is
     (declare P : constant Offset := Space_End (Text, Position);
      begin
        (if P = Items.Last then End_Member
         elsif P >= Items.Last or else Bytes.Get (Text, P) /= '{' then Bad_Member
         else
           (declare L : constant Offset := Value_Spec (Text, P);
            begin
              (if L = 0 or else L >= Items.Last then Bad_Member
               else
                 (declare T : constant Offset := Space_End (Text, L + 1);
                  begin
                    (if T = Items.Last then (Present, Missing, (P, L), T)
                     elsif T >= Items.Last or else Bytes.Get (Text, T) /= ',' then Bad_Member
                     else
                       (declare N : constant Offset := Space_End (Text, T + 1);
                        begin
                          (if N >= Items.Last then Bad_Member
                           else (Present, Missing, (P, L), N)))))))));

   --  Bounded fields can be viewed as Strings even when their source positions
   --  are beyond every machine-sized report buffer. First is one-based.
   function Window_Matches
     (Raw : Bytes.Sequence; First : Offset; Text : String) return Boolean is
     (First >= 1 and then First - 1 + To_Big_Integer (Text'Length) <= Bytes.Length (Raw)
      and then (for all I in Text'Range =>
        Bytes.Get (Raw, First + To_Big_Integer (I - Text'First)) = Text (I)));

   function Window (Raw : Bytes.Sequence; First : Offset; Count : Natural)
     return String
     with Global => null,
       Pre => First >= 1
         and then First - 1 + To_Big_Integer (Count) <= Bytes.Length (Raw),
       Post => Window'Result'First = 1 and then Window'Result'Length = Count
         and then Window_Matches (Raw, First, Window'Result);

   function From_String (Text : String) return Bytes.Sequence
     with Global => null,
       Post => Bytes.Length (From_String'Result) = To_Big_Integer (Text'Length)
         and then Window_Matches (From_String'Result, 1, Text);

   procedure Matching_Windows
     (Raw : Bytes.Sequence; First : Offset; Left, Right : String)
     with Global => null,
       Pre => Left'First = 1 and then Right'First = 1
         and then Left'Length = Right'Length
         and then Window_Matches (Raw, First, Left)
         and then Window_Matches (Raw, First, Right),
       Post => Left = Right;
end Silver_Report_Observations;
