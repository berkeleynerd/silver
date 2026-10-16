with SPARK.Big_Integers;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Observations;
with Silver_Report_Observations;

--  Independent value endpoints in the complete output, proved from actual
--  retained bytes or the precise two-byte tree replacement.
package Silver_Report_Projection_Value_Mapping
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Values renames Silver_Report_Projection_Values;
   package Structure renames Silver_Report_Projection_Structure;
   package Spans renames Silver_Report_Projection_Spans;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Relations renames Silver_Report_Projection_Observations;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   procedure Tree_Value (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Values.Ready (Raw, Start)
         and then Structure.Tree_Value_Context (Model.Scan_State (Raw, Start - 1)),
       Post =>
         Relations.Empty_Object (Mapping.Output (Raw),
           Mapping.Mapped (Raw, Start, Scan.Value_Spec (Raw, Start)))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Start)) =
           Mapping.Last (Raw, Scan.Value_Spec (Raw, Start));

   procedure Retained_Value (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Values.Ready (Raw, Start) and then Values.Retained_Value (Raw, Start)
         and then Scan.Value_Spec (Raw, Start) >= Start
         and then Scan.Value_Spec (Raw, Start) < Bytes.Length (Raw)
         and then Spans.Retained
           (Raw, Scan.Value_Spec (Raw, Start) + 1, Scan.Value_Spec (Raw, Start) + 1),
       Post =>
         Relations.Same_Content (Raw, (Start, Scan.Value_Spec (Raw, Start)),
           Mapping.Output (Raw), Mapping.Mapped (Raw, Start, Scan.Value_Spec (Raw, Start)))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Start)) =
           Mapping.Last (Raw, Scan.Value_Spec (Raw, Start));

   procedure Retained_Skip
     (Raw : Bytes.Sequence; Start, Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Values.Ready (Raw, Start) and then Values.Retained_Value (Raw, Start)
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Start)
         and then Level > 0 and then Level <= Model.Scan_State (Raw, Start - 1).Depth,
       Post => Scan.Value_From
         (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Start),
          Openers, Level, False, False, True) =
           Scan.Value_From
             (Mapping.Output (Raw), Outer_Start,
              Mapping.Last (Raw, Scan.Value_Spec (Raw, Start)) + 1,
              Openers, Level, False, False, True);
end Silver_Report_Projection_Value_Mapping;
