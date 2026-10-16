with SPARK.Big_Integers;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;
with Silver_Report_Projection_Observations;

--  Lift emitted prefix intervals to byte observations in the complete output.
package Silver_Report_Projection_Mapping
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Spans renames Silver_Report_Projection_Spans;
   package Scan renames Silver_Report_Observations;
   package Relations renames Silver_Report_Projection_Observations;
   package Bytes renames Model.Byte_Sequences;
   use type Bytes.Sequence;

   function Output (Raw : Bytes.Sequence) return Bytes.Sequence is
     (Model.Scan_Bytes (Raw, Bytes.Length (Raw)));

   function First (Raw : Bytes.Sequence; Position : Big_Natural) return Big_Natural is
     (Bytes.Length (Model.Scan_Bytes (Raw, Position - 1)) + 1)
     with Pre => Position >= 1 and then Position <= Bytes.Length (Raw) + 1;

   function Last (Raw : Bytes.Sequence; Position : Big_Natural) return Big_Natural is
     (Bytes.Length (Model.Scan_Bytes (Raw, Position)))
     with Pre => Position <= Bytes.Length (Raw);

   function Mapped (Raw : Bytes.Sequence; Low, High : Big_Natural) return Scan.Span is
     ((First (Raw, Low), Last (Raw, High)))
     with Pre => Low >= 1 and then Low <= High + 1 and then High <= Bytes.Length (Raw);

   procedure Exact_Content (Raw : Bytes.Sequence; Low, High : Big_Natural)
     with Global => null,
       Pre => Low >= 1 and then Low <= High and then High <= Bytes.Length (Raw)
         and then Spans.Exact_Range (Raw, Low, High),
       Post => Relations.Same_Content (Raw, (Low, High), Output (Raw), Mapped (Raw, Low, High));

   procedure Tree_Content (Raw : Bytes.Sequence; Low, High : Big_Natural)
     with Global => null,
       Pre => Low >= 1 and then Low <= High and then High <= Bytes.Length (Raw)
         and then Model.Scan_Bytes (Raw, High) =
           Bytes.Add (Bytes.Add (Model.Scan_Bytes (Raw, Low - 1), '{'), '}'),
       Post => Relations.Empty_Object (Output (Raw), Mapped (Raw, Low, High));

   procedure Emission_At (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Position >= 1 and then Position <= Bytes.Length (Raw),
       Post => Last (Raw, Position) = First (Raw, Position) - 1 +
         To_Big_Integer (Model.Advance_Spec
           (Model.Scan_State (Raw, Position - 1), Bytes.Get (Raw, Position)).Length)
         and then Last (Raw, Position) <= Bytes.Length (Output (Raw))
         and then (for all I in 1 .. Model.Advance_Spec
           (Model.Scan_State (Raw, Position - 1), Bytes.Get (Raw, Position)).Length =>
             Bytes.Get (Output (Raw), First (Raw, Position) + To_Big_Integer (I) - 1) =
               Model.Advance_Spec
                 (Model.Scan_State (Raw, Position - 1), Bytes.Get (Raw, Position)).Bytes (I));

   procedure Nonempty_Range (Raw : Bytes.Sequence; Low, High : Big_Natural)
     with Global => null,
       Pre => Low >= 1 and then Low <= High and then High <= Bytes.Length (Raw)
         and then Model.Advance_Spec
           (Model.Scan_State (Raw, Low - 1), Bytes.Get (Raw, Low)).Length > 0,
       Post => Scan.Valid (Output (Raw), Mapped (Raw, Low, High));
end Silver_Report_Projection_Mapping;
