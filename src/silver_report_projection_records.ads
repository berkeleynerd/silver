with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Member_Bounds;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Observations;
with Silver_Report_Observations;

package Silver_Report_Projection_Records
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bounds renames Silver_Report_Projection_Member_Bounds;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Relations renames Silver_Report_Projection_Observations;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   function Ready (Raw : Bytes.Sequence; Object : Scan.Span) return Boolean is
     (Bounds.Container_At (Raw, Object, Object_Container)
      and then Model.Scan_State (Raw, Object.First).Depth = 3
      and then Model.Scan_State (Raw, Object.First).Stack (3).Role = Check_Record);

   procedure Record_Projection (Raw : Bytes.Sequence; Object : Scan.Span)
     with Global => null, Pre => Ready (Raw, Object),
       Post => Relations.Check_Record
         (Raw, Object, Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Object.First)) =
           Mapping.Last (Raw, Object.Last);

   procedure Record_Skip
     (Raw : Bytes.Sequence; Object : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
     with Global => null,
       Pre => Ready (Raw, Object)
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Object.First)
         and then Level in 1 .. 2,
       Post => Scan.Value_From
         (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Object.First),
          Openers, Level, False, False, True) =
           Scan.Value_From
             (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Object.Last) + 1,
              Openers, Level, False, False, True);
end Silver_Report_Projection_Records;
