with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Values;

--  The state immediately after an actual container opener, independently of
--  the later member traversal and endpoint proofs.
package Silver_Report_Projection_Entry
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Values renames Silver_Report_Projection_Values;
   package Bytes renames Model.Byte_Sequences;

   procedure Enter_Container (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Values.Ready (Raw, Start) and then Bytes.Get (Raw, Start) in '{' | '[',
       Post => Model.Scan_State (Raw, Start).Depth > 0
         and then Model.Scan_State (Raw, Start).Depth = Model.Scan_State (Raw, Start - 1).Depth + 1
         and then Model.Scan_State (Raw, Start).Mode = Between_Tokens
         and then Model.Scan_State (Raw, Start).Stack (Model.Scan_State (Raw, Start).Depth).Role =
           Model.Child_Role (Model.Scan_State (Raw, Start - 1), Bytes.Get (Raw, Start));
end Silver_Report_Projection_Entry;
