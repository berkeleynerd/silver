with Silver_Report_Projection_Member_Steps;
with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Windows;
with Silver_Report_Projection_Continuations;
package body Silver_Report_Projection_Value_Mapping with SPARK_Mode => On is
   package Steps renames Silver_Report_Projection_Member_Steps;
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Windows renames Silver_Report_Observation_Windows;
   package Continuations renames Silver_Report_Projection_Continuations;

   procedure Tree_Value (Raw : Bytes.Sequence; Start : Big_Natural) is
   begin
      Values.Tree_Projection (Raw, Start);
      Mapping.Tree_Content (Raw, Start, Scan.Value_Spec (Raw, Start));
   end Tree_Value;

   procedure Retained_Value (Raw : Bytes.Sequence; Start : Big_Natural) is
      Last : constant Big_Natural := Scan.Value_Spec (Raw, Start);
   begin
      Values.Retained_Projection (Raw, Start);
      Mapping.Exact_Content (Raw, Start, Last);
      Steps.Join_Retained (Raw, Start, Last, Last + 1);
      Spans.Retained_Range (Raw, Start, Last + 1);
      Projected_Windows.Exact_Window (Raw, Start, Last + 1);
      Windows.Value_Spec_Window
        (Raw, Mapping.Output (Raw), Start, Last + 1, Start,
         Projected_Windows.Shift (Raw, Start));
   end Retained_Value;

   procedure Retained_Skip
     (Raw : Bytes.Sequence; Start, Outer_Start : Big_Natural;
      Openers : Scan.Nesting; Level : Scan.Nesting_Level)
   is
   begin
      Values.Retained_Projection (Raw, Start);
      Projected_Windows.Exact_Window (Raw, Start, Scan.Value_Spec (Raw, Start));
      Continuations.Retained_Value_Skip
        (Raw, Mapping.Output (Raw), Start, Scan.Value_Spec (Raw, Start), Outer_Start,
         Projected_Windows.Shift (Raw, Start), Openers, Level);
   end Retained_Skip;
end Silver_Report_Projection_Value_Mapping;
