with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Syntax;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

--  A number ends on its following delimiter. These lemmas cover that last
--  transition as well as values whose closing byte already ended their token.
package Silver_Report_Projection_Separators
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Syntax renames Silver_Report_Projection_Syntax;
   package Spans renames Silver_Report_Projection_Spans;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   function After_Value (S : State) return Boolean is
     (S.Depth > 0 and then
       ((S.Mode = Between_Tokens
           and then S.Stack (S.Depth).Position in Object_Separator | Array_Separator)
        or else (S.Mode = In_Number and then Model.Terminal_Number (S.Number))));

   function Ended (S : State) return State is
     (if S.Mode = In_Number then Model.Ended ((S with delta Mode => Between_Tokens))
      else S);

   procedure Space_After_Value (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then After_Value (Model.Scan_State (Raw, Position - 1)),
       Post => Observations.Space_End (Raw, Position) <= Bytes.Length (Raw)
         and then not Observations.Space
           (Bytes.Get (Raw, Observations.Space_End (Raw, Position)))
         and then Model.Scan_State
           (Raw, Observations.Space_End (Raw, Position) - 1) =
             (if Observations.Space_End (Raw, Position) > Position then
                Ended (Model.Scan_State (Raw, Position - 1))
              else Model.Scan_State (Raw, Position - 1))
         and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
           Spans.Retained (Raw, Position, Observations.Space_End (Raw, Position) - 1));

   procedure Separator_Context (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then After_Value (Model.Scan_State (Raw, Position - 1))
         and then (if Model.Scan_State (Raw, Position - 1).Mode = In_Number then
           Position <= Bytes.Length (Raw)
           and then Model.Number_Ends (Model.Scan_State (Raw, Position - 1).Number,
                                      Bytes.Get (Raw, Position))),
       Post => Observations.Space_End (Raw, Position) <= Bytes.Length (Raw)
         and then
           (declare Before : constant State := Model.Scan_State (Raw, Position - 1);
                    P : constant Big_Natural := Observations.Space_End (Raw, Position);
                    C : constant Character := Bytes.Get (Raw, P);
            begin (C = ',' or else
              (if Before.Stack (Before.Depth).Container = Object_Container then C = '}' else C = ']'))
              and then Model.Scan_State (Raw, P) = Model.Advance_Spec (Ended (Before), C).Following
              and then (if Model.Keeping (Before) then
                Spans.Retained (Raw, Position, P)));
end Silver_Report_Projection_Separators;
