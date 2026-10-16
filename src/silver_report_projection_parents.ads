with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;

--  Parent frames are independent of bytes inside the value they contain.
package Silver_Report_Projection_Parents
  with SPARK_Mode => On, Ghost => Static
is
   use Silver_Report_Projection_Types;
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;
   package Bytes renames Model.Byte_Sequences;

   function Same (Left, Right : State; Base : Depth_Range) return Boolean is
     (Left.Depth >= Base and then Right.Depth >= Base
      and then (for all I in 1 .. Base =>
        (if I < Base then Left.Stack (I) = Right.Stack (I)
         else Left.Stack (I).Container = Right.Stack (I).Container
           and then Left.Stack (I).Role = Right.Stack (I).Role
           and then Left.Stack (I).Key = Right.Stack (I).Key
           and then Left.Stack (I).Keep = Right.Stack (I).Keep)));

   function Whole (Left, Right : State; Base : Depth_Range) return Boolean is
     (Left.Depth >= Base and then Right.Depth >= Base
      and then (for all I in 1 .. Base => Left.Stack (I) = Right.Stack (I)));

   procedure Same_Transitive (Left, Middle, Right : State; Base : Depth_Range)
     with Global => null, Pre => Same (Left, Middle, Base) and then Same (Middle, Right, Base),
       Post => Same (Left, Right, Base);

   procedure Whole_Transitive (Left, Middle, Right : State; Base : Depth_Range)
     with Global => null, Pre => Whole (Left, Middle, Base) and then Whole (Middle, Right, Base),
       Post => Whole (Left, Right, Base);

   procedure Lift_Whole
     (Raw : Bytes.Sequence; First, Last : Big_Natural;
      Left, Middle : State; Base : Depth_Range)
     with Global => null,
       Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw)
         and then Whole (Left, Middle, Base)
         and then (for all I in Raw =>
           (if First <= I and then I <= Last then Whole (Middle, Model.Scan_State (Raw, I - 1), Base))),
       Post => (for all I in Raw =>
         (if First <= I and then I <= Last then Whole (Left, Model.Scan_State (Raw, I - 1), Base))),
       Subprogram_Variant => (Decreases => Last + 1 - First);

   function Value_Starter (Item : Character) return Boolean is
     (Item in '{' | '[' | '"' | '-' | '0' .. '9' | 't' | 'f' | 'n');

   function Ready_Value (S : State; Item : Character) return Boolean is
     (S.Mode = Between_Tokens and then not S.Finished and then Value_Starter (Item)
      and then (if S.Depth = 0 then not S.Started
        else Structure.Awaits_Value (S.Stack (S.Depth))));

   procedure Inside_Container (S : State; Item : Character; Base : Depth_Range)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Base < S.Depth
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Same (S, Model.Advance_Spec (S, Item).Following, Base)
         and then (if Model.Advance_Spec (S, Item).Following.Depth > Base then
           Whole (S, Model.Advance_Spec (S, Item).Following, Base));

   procedure Inside_Token (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Mode /= Between_Tokens
         and then (if Structure.String_Mode (S) then not S.String_Is_Key)
         and then (if S.Mode = In_Number then not Model.Number_Ends (S.Number, Item))
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Same (S, Model.Advance_Spec (S, Item).Following, S.Depth)
         and then Model.Advance_Spec (S, Item).Following.Token_Keep = S.Token_Keep
         and then (if Model.Advance_Spec (S, Item).Following.Mode /= Between_Tokens then
           Whole (S, Model.Advance_Spec (S, Item).Following, S.Depth));

   procedure Start_Value (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Ready_Value (S, Item)
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Whole (S, Model.Advance_Spec (S, Item).Following, S.Depth);
end Silver_Report_Projection_Parents;
