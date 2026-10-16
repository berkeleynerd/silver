with SPARK.Big_Integers;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Mapping;
with Silver_Report_Observation_Windows;

--  Turn exact stream emissions into the shifted windows consumed by the
--  independent scanner correspondence lemmas.
package Silver_Report_Projection_Windows
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Spans renames Silver_Report_Projection_Spans;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Windows renames Silver_Report_Observation_Windows;
   package Bytes renames Model.Byte_Sequences;

   function Shift (Raw : Bytes.Sequence; Position : Big_Natural) return Big_Integer is
     (Mapping.First (Raw, Position) - Position)
     with Pre => Position >= 1 and then Position <= Bytes.Length (Raw) + 1;

   procedure Exact_Window (Raw : Bytes.Sequence; Low, High : Big_Natural)
     with Global => null,
       Pre => Low >= 1 and then Low <= High and then High <= Bytes.Length (Raw)
         and then Spans.Exact_Range (Raw, Low, High),
       Post => Windows.Same_Window
         (Raw, Mapping.Output (Raw), Low, High, Shift (Raw, Low));

   procedure Offset_Within
     (Raw : Bytes.Sequence; Low, High, Position : Big_Natural)
     with Global => null,
       Pre => Low >= 1 and then Low <= High + 1 and then High <= Bytes.Length (Raw)
         and then Position >= Low and then Position <= High + 1
         and then Spans.Retained (Raw, Low, High),
       Post => Mapping.First (Raw, Position) = Mapping.First (Raw, Low) + Position - Low;
end Silver_Report_Projection_Windows;
