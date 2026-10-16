with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Member_Bounds;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Observations;
with Silver_Report_Observations;

package Silver_Report_Projection_Lists
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

   function Ready (Raw : Bytes.Sequence; Items : Scan.Span) return Boolean is
     (Bounds.Container_At (Raw, Items, Array_Container)
      and then Model.Scan_State (Raw, Items.First).Depth = 2
      and then Model.Scan_State (Raw, Items.First).Stack (2).Role = Check_List);

   procedure List_Projection (Raw : Bytes.Sequence; Items : Scan.Span)
     with Global => null, Pre => Ready (Raw, Items),
       Post => Relations.Check_List
         (Raw, Items, Mapping.Output (Raw), Mapping.Mapped (Raw, Items.First, Items.Last))
         and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, Items.First)) =
           Mapping.Last (Raw, Items.Last);

   procedure List_Skip
     (Raw : Bytes.Sequence; Items : Scan.Span; Outer_Start : Big_Natural;
      Openers : Scan.Nesting)
     with Global => null,
       Pre => Ready (Raw, Items)
         and then Outer_Start >= 1 and then Outer_Start <= Mapping.First (Raw, Items.First),
       Post => Scan.Value_From
         (Mapping.Output (Raw), Outer_Start, Mapping.First (Raw, Items.First),
          Openers, 1, False, False, True) =
           Scan.Value_From
             (Mapping.Output (Raw), Outer_Start, Mapping.Last (Raw, Items.Last) + 1,
              Openers, 1, False, False, True);
end Silver_Report_Projection_Lists;
