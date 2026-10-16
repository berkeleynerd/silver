with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Mapping;
with Silver_Report_Observations;

--  Complete-stream root framing, including all leading and trailing trivia.
package Silver_Report_Projection_Roots
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Spans renames Silver_Report_Projection_Spans;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   procedure Root_Start (Raw : Bytes.Sequence)
     with Global => null, Pre => Bridge.Complete (Raw),
       Post => Scan.Space_End (Raw, 1) <= Bytes.Length (Raw)
         and then Model.Scan_State (Raw, Scan.Space_End (Raw, 1) - 1) = Initial_State
         and then Spans.Retained (Raw, 1, Scan.Space_End (Raw, 1) - 1);

   function Root_Ended (S : State) return Boolean is
     (not S.Failed and then S.Finished and then S.Depth = 0 and then S.Mode = Between_Tokens);

   procedure Suffix (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then Root_Ended (Model.Scan_State (Raw, Position - 1)),
       Post => Scan.Space_End (Raw, Position) = Bytes.Length (Raw) + 1
         and then Spans.Retained (Raw, Position, Bytes.Length (Raw)),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position);

   procedure Projected_Suffix (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then Root_Ended (Model.Scan_State (Raw, Position - 1)),
       Post => Scan.Space_End (Mapping.Output (Raw), Mapping.First (Raw, Position)) =
         Bytes.Length (Mapping.Output (Raw)) + 1;
end Silver_Report_Projection_Roots;
