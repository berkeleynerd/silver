with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Member_Bounds;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Observations;
with Silver_Report_Observations;

--  From the actual complete streaming projection to independent structural
--  observations. No target acceptance, scanner endpoint or relation is assumed.
package Silver_Report_Projection_Composition
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

   procedure Actual_Projection (Raw : Bytes.Sequence)
     with Global => null,
       Pre => Silver_Report_Projection_Bridge.Complete (Raw),
       Post => Relations.Audit_Projection_Observations (Raw, Mapping.Output (Raw));
end Silver_Report_Projection_Composition;
