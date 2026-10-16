with SPARK.Big_Integers;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Mapping;
with Silver_Report_Observations;

--  Only a root object can introduce the flow/proof record roles. Complete
--  arrays and scalar roots retain every byte, including a primitive at EOF.
package Silver_Report_Projection_Nonobjects
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   use type Bytes.Sequence;

   procedure Unchanged (Raw : Bytes.Sequence)
     with Global => null,
       Pre => Bridge.Complete (Raw)
         and then Scan.Space_End (Raw, 1) <= Bytes.Length (Raw)
         and then Bytes.Get (Raw, Scan.Space_End (Raw, 1)) /= '{',
       Post => Mapping.Output (Raw) = Raw;
end Silver_Report_Projection_Nonobjects;
