with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

--  Key classification is tied to the original quoted bytes, including escape
--  spelling. It is not inferred from the projection's acceptance decision.
package Silver_Report_Projection_Keys
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Structure renames Silver_Report_Projection_Structure;
   package Spans renames Silver_Report_Projection_Spans;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   Flow_Name : constant String := "flow";
   Proof_Name : constant String := "proof";
   Tree_Name : constant String := "check_tree";

   function Word
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Name : String)
      return Boolean is
     (Last = First + To_Big_Integer (Name'Length) + 1
      and then Bytes.Get (Raw, First) = '"'
      and then Bytes.Get (Raw, Last) = '"'
      and then (for all I in Name'Range =>
        Bytes.Get (Raw, First + To_Big_Integer (I - Name'First) + 1) = Name (I)))
     with Pre => First >= 1 and then Last >= First
       and then Last <= Bytes.Length (Raw);

   function Raw_Key
     (Raw : Bytes.Sequence; First, Last : Big_Natural) return Key_Kind is
     (if Word (Raw, First, Last, Flow_Name) then Flow_Key
      elsif Word (Raw, First, Last, Proof_Name) then Proof_Key
      elsif Word (Raw, First, Last, Tree_Name) then Tree_Key
      else Other_Key)
     with Pre => First >= 1 and then Last >= First
       and then Last <= Bytes.Length (Raw);

   function Frames_Preserved (Left, Right : State; Base : Positive) return Boolean is
     (Base <= Left.Depth and then Base <= Right.Depth
      and then (for all I in 1 .. Base =>
        (if I < Base then Left.Stack (I) = Right.Stack (I)
         else Left.Stack (I).Container = Right.Stack (I).Container
           and then Left.Stack (I).Role = Right.Stack (I).Role
           and then Left.Stack (I).Keep = Right.Stack (I).Keep)));

   function Key_Interior
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Base : Positive) return Boolean is
     (for all I in Raw =>
       (if First <= I and then I <= Last then
         Model.Scan_State (Raw, I - 1).Depth = Base
         and then Structure.String_Mode (Model.Scan_State (Raw, I - 1))
         and then Model.Scan_State (Raw, I - 1).String_Is_Key))
     with Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw);

   procedure Key_Boundary (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Start >= 1
         and then Start <= Bytes.Length (Raw)
         and then Model.Scan_State (Raw, Start - 1).Mode = Between_Tokens
         and then Model.Scan_State (Raw, Start - 1).Depth > 0
         and then Model.Scan_State (Raw, Start - 1).Stack
           (Model.Scan_State (Raw, Start - 1).Depth).Position in First_Key | Next_Key
         and then Bytes.Get (Raw, Start) = '"',
       Post => Observations.Value_Spec (Raw, Start) >= Start
         and then Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)).Depth =
           Model.Scan_State (Raw, Start - 1).Depth
         and then Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)).Mode =
           Between_Tokens
         and then Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)).Stack
           (Model.Scan_State (Raw, Start - 1).Depth).Position = Colon
         and then Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)).Stack
           (Model.Scan_State (Raw, Start - 1).Depth).Key =
             Raw_Key (Raw, Start, Observations.Value_Spec (Raw, Start))
         and then Frames_Preserved
           (Model.Scan_State (Raw, Start - 1),
            Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)),
            Model.Scan_State (Raw, Start - 1).Depth)
         and then Key_Interior
           (Raw, Start + 1, Observations.Value_Spec (Raw, Start),
            Model.Scan_State (Raw, Start - 1).Depth)
         and then (if Model.Keeping (Model.Scan_State (Raw, Start - 1)) then
           Spans.Retained (Raw, Start, Observations.Value_Spec (Raw, Start)));
end Silver_Report_Projection_Keys;
