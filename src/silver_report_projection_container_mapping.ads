with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Member_Bounds;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Mapping;
with Silver_Report_Observations;

--  Root, check-list and check-record containers retain their delimiters.
package Silver_Report_Projection_Container_Mapping
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bounds renames Silver_Report_Projection_Member_Bounds;
   package Spans renames Silver_Report_Projection_Spans;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   procedure Container_Content
     (Raw : Bytes.Sequence; Object : Scan.Span; Kind : Container_Kind)
     with Global => null,
       Pre => Bounds.Container_At (Raw, Object, Kind)
         and then Model.Scan_State (Raw, Object.First).Depth <= 3,
       Post => Spans.Retained (Raw, Object.First, Object.First)
         and then Spans.Retained (Raw, Object.Last, Object.Last)
         and then Model.Scan_State (Raw, Object.Last - 1).Depth =
           Model.Scan_State (Raw, Object.First).Depth
         and then Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Bytes.Get (Mapping.Output (Raw), Mapping.First (Raw, Object.First)) =
           Bytes.Get (Raw, Object.First)
         and then Bytes.Get (Mapping.Output (Raw), Mapping.Last (Raw, Object.Last)) =
           Bytes.Get (Raw, Object.Last)
         and then Mapping.First (Raw, Object.First + 1) = Mapping.First (Raw, Object.First) + 1
         and then Mapping.First (Raw, Object.Last) = Mapping.Last (Raw, Object.Last);

   procedure Cursor_Content
     (Raw : Bytes.Sequence; Object : Scan.Span; Position : Big_Natural; Kind : Container_Kind)
     with Global => null,
       Pre => Bounds.Cursor_Ready (Raw, Object, Position, Kind)
         and then Model.Scan_State (Raw, Object.First).Depth <= 3,
       Post => Model.Scan_State (Raw, Position - 1).Depth = Model.Scan_State (Raw, Object.First).Depth
         and then Model.Keeping (Model.Scan_State (Raw, Position - 1))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Object.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Object.Last);
end Silver_Report_Projection_Container_Mapping;
