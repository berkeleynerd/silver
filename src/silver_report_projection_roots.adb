with Silver_Report_Projection_Syntax;
with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Windows;
package body Silver_Report_Projection_Roots with SPARK_Mode => On is
   package Syntax renames Silver_Report_Projection_Syntax;
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Windows renames Silver_Report_Observation_Windows;

   procedure Finished_Step (S : State; C : Character)
     with Global => null,
       Pre => Root_Ended (S) and then not Model.Advance_Spec (S, C).Following.Failed,
       Post => Scan.Space (C) and then Model.Advance_Spec (S, C).Following = S
         and then Model.Advance_Spec (S, C).Length = 1
         and then Model.Advance_Spec (S, C).Bytes (1) = C
   is
   begin
      null;
   end Finished_Step;

   procedure Root_Start (Raw : Bytes.Sequence) is
   begin
      Syntax.Space_Context (Raw, 1);
   end Root_Start;

   procedure Suffix (Raw : Bytes.Sequence; Position : Big_Natural) is
   begin
      if Position <= Bytes.Length (Raw) then
         Bridge.Prefix_Context (Raw, Position);
         Finished_Step (Model.Scan_State (Raw, Position - 1), Bytes.Get (Raw, Position));
         Suffix (Raw, Position + 1);
      end if;
   end Suffix;

   procedure Projected_Suffix (Raw : Bytes.Sequence; Position : Big_Natural) is
   begin
      Suffix (Raw, Position);
      Spans.Output_Prefix (Raw, Position - 1, Bytes.Length (Raw));
      if Position <= Bytes.Length (Raw) then
         Spans.Retained_Range (Raw, Position, Bytes.Length (Raw));
         Projected_Windows.Exact_Window (Raw, Position, Bytes.Length (Raw));
         Windows.Space_End_Equivalent
           (Raw, Mapping.Output (Raw), Position, Bytes.Length (Raw), Position,
            Projected_Windows.Shift (Raw, Position));
      end if;
   end Projected_Suffix;
end Silver_Report_Projection_Roots;
