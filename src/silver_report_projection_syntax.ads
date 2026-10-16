with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Bridge;
with Silver_Report_Observations;
with Silver_Report_Projection_Spans;

--  Byte-scanner trivia and punctuation correspond to actual stream states.
package Silver_Report_Projection_Syntax
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Bridge renames Silver_Report_Projection_Bridge;
   package Observations renames Silver_Report_Observations;
   package Spans renames Silver_Report_Projection_Spans;
   package Bytes renames Model.Byte_Sequences;

   procedure Space_Context (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then Model.Scan_State (Raw, Position - 1).Mode = Between_Tokens,
       Post => Model.Scan_State
         (Raw, Observations.Space_End (Raw, Position) - 1) =
           Model.Scan_State (Raw, Position - 1)
         and then (if Observations.Space_End (Raw, Position) <= Bytes.Length (Raw) then
           not Observations.Space (Bytes.Get (Raw, Observations.Space_End (Raw, Position))))
         and then (for all I in Raw =>
           (if Position <= I and then I < Observations.Space_End (Raw, Position) then
             Observations.Space (Bytes.Get (Raw, I))))
         and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
           Spans.Retained (Raw, Position, Observations.Space_End (Raw, Position) - 1)),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position);

   procedure Colon_Context (Raw : Bytes.Sequence; Position : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Position >= 1
         and then Position <= Bytes.Length (Raw) + 1
         and then Model.Scan_State (Raw, Position - 1).Mode = Between_Tokens
         and then Model.Scan_State (Raw, Position - 1).Depth > 0
         and then Model.Scan_State (Raw, Position - 1).Stack
           (Model.Scan_State (Raw, Position - 1).Depth).Position = Colon,
       Post => Observations.Space_End (Raw, Position) <= Bytes.Length (Raw)
         and then Bytes.Get (Raw, Observations.Space_End (Raw, Position)) = ':'
         and then
           (declare Before : constant State := Model.Scan_State (Raw, Position - 1);
                    After : constant State := Model.Scan_State
                      (Raw, Observations.Space_End (Raw, Position));
            begin After = (Before with delta Stack =>
              (Before.Stack with delta Before.Depth =>
                (Before.Stack (Before.Depth) with delta Position => Object_Value))))
         and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
           Spans.Retained (Raw, Position, Observations.Space_End (Raw, Position)));
end Silver_Report_Projection_Syntax;
