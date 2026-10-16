with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Bridge;
with Silver_Report_Observations;
with Silver_Report_Projection_Parents;

--  Independent auditor boundaries for scalar JSON values.
package Silver_Report_Projection_Tokens
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   package Parents renames Silver_Report_Projection_Parents;

   function String_Context (S : State; Base : Depth_Range; Escaped : Boolean)
     return Boolean is
     (S.Depth = Base and then Structure.String_Mode (S)
      and then not S.String_Is_Key and then Escaped = (S.Mode = After_Escape));

   procedure String_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural;
      Base : Depth_Range; Escaped : Boolean)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Start >= 1 and then Start < Position
         and then Position <= Bytes.Length (Raw) + 1
         and then String_Context (Model.Scan_State (Raw, Position - 1), Base, Escaped),
       Post => Observations.Value_From
         (Raw, Start, Position, Observations.Empty_Nesting, 0, True, Escaped, False) >= Position
         and then Bridge.End_Context
           (Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True, Escaped, False)), Base)
         and then Parents.Same
           (Model.Scan_State (Raw, Position - 1),
            Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True, Escaped, False)), Base)
         and then (for all I in Raw =>
           (if Position <= I and then I <= Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True, Escaped, False) then
             Model.Scan_State (Raw, I - 1).Depth = Base
             and then Structure.String_Mode (Model.Scan_State (Raw, I - 1))
             and then not Model.Scan_State (Raw, I - 1).String_Is_Key
             and then Parents.Whole
               (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, I - 1), Base))),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position);

   function Primitive_Context (S : State; Base : Depth_Range) return Boolean is
     (Base > 0 and then S.Depth = Base
      and then S.Mode in In_Number | In_Literal | Between_Tokens
      and then (if S.Mode = Between_Tokens then
        S.Stack (Base).Position in Object_Separator | Array_Separator
        else Structure.Awaits_Value (S.Stack (Base))));

   function Primitive_End_Context (S : State; Base : Depth_Range) return Boolean is
     (S.Depth = Base and then Base > 0
      and then ((S.Mode = Between_Tokens
                   and then S.Stack (Base).Position in Object_Separator | Array_Separator)
        or else (S.Mode = In_Number and then Model.Terminal_Number (S.Number))));

   function Number_Boundary (Raw : Bytes.Sequence; Last : Big_Natural) return Boolean is
     (if Model.Scan_State (Raw, Last).Mode = In_Number then
        Last < Bytes.Length (Raw) and then Model.Number_Ends
          (Model.Scan_State (Raw, Last).Number, Bytes.Get (Raw, Last + 1)))
     with Pre => Last <= Bytes.Length (Raw);

   procedure Primitive_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural; Base : Depth_Range)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Start >= 1 and then Start < Position
         and then Position <= Bytes.Length (Raw) + 1
         and then Primitive_Context (Model.Scan_State (Raw, Position - 1), Base),
       Post => Observations.Value_From
         (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False) >= Position - 1
         and then Primitive_End_Context
           (Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False)), Base)
         and then Number_Boundary (Raw, Observations.Value_From
           (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False))
         and then Parents.Same
           (Model.Scan_State (Raw, Position - 1),
            Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False)), Base)
         and then (for all I in Raw =>
           (if Position <= I and then I <= Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False) then
             Model.Scan_State (Raw, I - 1).Depth = Base
             and then Model.Scan_State (Raw, I - 1).Mode in In_Number | In_Literal
             and then (if Model.Scan_State (Raw, I - 1).Mode = In_Number then
               not Model.Number_Ends (Model.Scan_State (Raw, I - 1).Number, Bytes.Get (Raw, I)))
             and then Parents.Whole
               (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, I - 1), Base))),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position);
end Silver_Report_Projection_Tokens;
