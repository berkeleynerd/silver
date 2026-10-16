with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Tokens;
with Silver_Report_Projection_Parents;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

--  Value boundaries and exact projected intervals used by member traversal.
package Silver_Report_Projection_Values
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Tokens renames Silver_Report_Projection_Tokens;
   package Parents renames Silver_Report_Projection_Parents;
   package Spans renames Silver_Report_Projection_Spans;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   use type Bytes.Sequence;

   function Ready (Raw : Bytes.Sequence; Start : Big_Natural) return Boolean is
     (Bridge.Complete (Raw) and then Start >= 1 and then Start <= Bytes.Length (Raw)
      and then Parents.Ready_Value
        (Model.Scan_State (Raw, Start - 1), Bytes.Get (Raw, Start))
      and then (Model.Scan_State (Raw, Start - 1).Depth > 0
        or else Bytes.Get (Raw, Start) in '{' | '['));

   function Finished_Value (S : State; Base : Depth_Range) return Boolean is
     (Bridge.End_Context (S, Base) or else Tokens.Primitive_End_Context (S, Base));

   function Inside_Value (S : State; Base : Depth_Range; Item : Character) return Boolean is
     (S.Depth > Base or else
       (S.Depth = Base and then S.Mode /= Between_Tokens
        and then (if Structure.String_Mode (S) then not S.String_Is_Key)
        and then (if S.Mode = In_Number then not Model.Number_Ends (S.Number, Item))));

   function Value_Shape (S : State; Base : Depth_Range; Starter : Character) return Boolean is
     (if Starter in '{' | '[' then Base < Max_Depth and then S.Depth > Base
        and then S.Stack (Base + 1).Container =
          (if Starter = '{' then Object_Container else Array_Container)
      else S.Depth = Base);

   procedure Value_Boundary (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null, Pre => Ready (Raw, Start),
       Post => Observations.Value_Spec (Raw, Start) >= Start
         and then Finished_Value
           (Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)),
            Model.Scan_State (Raw, Start - 1).Depth)
         and then Tokens.Number_Boundary (Raw, Observations.Value_Spec (Raw, Start))
         and then Parents.Same
           (Model.Scan_State (Raw, Start - 1),
            Model.Scan_State (Raw, Observations.Value_Spec (Raw, Start)),
            Model.Scan_State (Raw, Start - 1).Depth)
         and then (for all I in Raw =>
           (if Start < I and then I <= Observations.Value_Spec (Raw, Start) then
             Parents.Whole
               (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, I - 1),
                Model.Scan_State (Raw, Start - 1).Depth)
             and then Inside_Value
               (Model.Scan_State (Raw, I - 1), Model.Scan_State (Raw, Start - 1).Depth,
                Bytes.Get (Raw, I))
             and then Value_Shape
               (Model.Scan_State (Raw, I - 1), Model.Scan_State (Raw, Start - 1).Depth,
                Bytes.Get (Raw, Start))));

   procedure Tree_Projection (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Ready (Raw, Start)
         and then Structure.Tree_Value_Context (Model.Scan_State (Raw, Start - 1)),
       Post => Observations.Value_Spec (Raw, Start) >= Start
         and then Model.Scan_Bytes (Raw, Observations.Value_Spec (Raw, Start)) =
           Bytes.Add (Bytes.Add (Model.Scan_Bytes (Raw, Start - 1), '{'), '}');

   function Retained_Context (S : State) return Boolean is
     ((S.Depth = 3 and then S.Stack (3).Role = Check_Record
         and then S.Stack (3).Key /= Tree_Key)
      or else (S.Depth = 1 and then S.Stack (1).Role = Root_Object
         and then S.Stack (1).Key not in Flow_Key | Proof_Key));

   function Retained_Value (Raw : Bytes.Sequence; Start : Big_Natural) return Boolean is
     (Retained_Context (Model.Scan_State (Raw, Start - 1))
      or else (Model.Scan_State (Raw, Start - 1).Depth = 1
        and then Model.Scan_State (Raw, Start - 1).Stack (1).Role = Root_Object
        and then Bytes.Get (Raw, Start) /= '[')
      or else (Model.Scan_State (Raw, Start - 1).Depth = 2
        and then Model.Scan_State (Raw, Start - 1).Stack (2).Role = Check_List
        and then Bytes.Get (Raw, Start) /= '{'))
     with Pre => Start >= 1 and then Start <= Bytes.Length (Raw);

   procedure Retained_Projection (Raw : Bytes.Sequence; Start : Big_Natural)
     with Global => null,
       Pre => Ready (Raw, Start) and then Retained_Value (Raw, Start),
       Post => Observations.Value_Spec (Raw, Start) >= Start
         and then Spans.Retained (Raw, Start, Observations.Value_Spec (Raw, Start))
         and then Spans.Exact_Range (Raw, Start, Observations.Value_Spec (Raw, Start));
end Silver_Report_Projection_Values;
