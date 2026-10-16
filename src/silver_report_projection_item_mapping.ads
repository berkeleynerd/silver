with SPARK.Big_Integers;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Members;
with Silver_Report_Observations;

--  Generic array traversal continues past values that the auditor classifies
--  as nonobject items. Its mapped endpoints still support the object-only view.
package Silver_Report_Projection_Item_Mapping
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Spans renames Silver_Report_Projection_Spans;
   package Members renames Silver_Report_Projection_Members;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   subtype Offset is Scan.Offset;
   use type Scan.Member_State;
   use type Scan.Member;
   use type Scan.Span;

   procedure Item_Identity
     (Text : Bytes.Sequence; Items : Scan.Span; Position : Offset)
     with Global => null,
       Pre => Scan.Valid (Text, Items) and then Position >= Items.First + 1
         and then Position <= Bytes.Length (Text) + 1,
       Post =>
         (declare M : constant Scan.Member := Members.Any_Item_Spec (Text, Items, Position);
          begin (if M.State = Scan.Present then
            Scan.Valid (Text, M.Value) and then M.Key = Scan.Missing
            and then M.Value.First = Scan.Space_End (Text, Position)
            and then M.Value.Last = Scan.Value_Spec (Text, M.Value.First)
            and then M.Value.First >= Position
            and then M.Value.Last < M.Next and then M.Next <= Items.Last)
          and then Scan.Item_Spec (Text, Items, Position) =
            (if M.State = Scan.Present and then Bytes.Get (Text, M.Value.First) /= '{'
             then Scan.Bad_Member else M));

   procedure Assemble_Present_Item
     (Raw : Bytes.Sequence; Items : Scan.Span; Position : Offset)
     with Global => null,
       Pre => Scan.Valid (Raw, Items)
         and then Items.First < Position and then Position <= Items.Last
         and then Spans.Retained (Raw, Items.First, Items.First)
         and then Spans.Retained (Raw, Items.Last, Items.Last)
         and then
           (declare M : constant Scan.Member := Members.Any_Item_Spec (Raw, Items, Position);
            begin M.State = Scan.Present and then Scan.Valid (Raw, M.Value)
              and then Position <= M.Value.First
              and then M.Value.Last < M.Next and then M.Next <= Items.Last
              and then Spans.Retained (Raw, Position, M.Value.First - 1)
              and then Spans.Retained (Raw, M.Value.Last + 1, M.Next)
              and then Scan.Valid
                (Mapping.Output (Raw), Mapping.Mapped (Raw, M.Value.First, M.Value.Last))
              and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, M.Value.First)) =
                Mapping.Last (Raw, M.Value.Last)),
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Items.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Items.Last)
         and then
           (declare M : constant Scan.Member := Members.Any_Item_Spec (Raw, Items, Position);
                    N : constant Scan.Member := Members.Any_Item_Spec
                      (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last),
                       Mapping.First (Raw, Position));
            begin N = (Scan.Present, Scan.Missing,
                        Mapping.Mapped (Raw, M.Value.First, M.Value.Last), Mapping.First (Raw, M.Next))
              and then Scan.Item_Spec (Raw, Items, Position) =
                (if Bytes.Get (Raw, M.Value.First) = '{' then M else Scan.Bad_Member)
              and then Scan.Item_Spec
                (Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last),
                 Mapping.First (Raw, Position)) =
                  (if Bytes.Get (Mapping.Output (Raw), N.Value.First) = '{' then N else Scan.Bad_Member));

   procedure Item_Head_Skip
     (Text : Bytes.Sequence; Items : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Scan.Valid (Text, Items) and then Start >= 1
         and then Start <= Position and then Position >= Items.First + 1
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0
         and then Members.Any_Item_Spec (Text, Items, Position).State = Scan.Present,
       Post => Scan.Value_From (Text, Start, Position, Openers, Level, False, False, True) =
         Scan.Value_From
           (Text, Start, Members.Any_Item_Spec (Text, Items, Position).Value.First,
            Openers, Level, False, False, True);

   procedure Item_Tail_Skip
     (Text : Bytes.Sequence; Items : Scan.Span; Start, Position : Offset;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Scan.Valid (Text, Items) and then Start >= 1
         and then Start <= Position and then Position >= Items.First + 1
         and then Position <= Bytes.Length (Text) + 1 and then Level > 0
         and then Members.Any_Item_Spec (Text, Items, Position).State = Scan.Present,
       Post => Scan.Value_From
         (Text, Start, Members.Any_Item_Spec (Text, Items, Position).Value.Last + 1,
          Openers, Level, False, False, True) =
           Scan.Value_From
             (Text, Start, Members.Any_Item_Spec (Text, Items, Position).Next,
              Openers, Level, False, False, True);
end Silver_Report_Projection_Item_Mapping;
