with Ada.Text_IO;
with Silver_Output_Profile;
with Silver_Application_Units;
procedure Admission_Probe is
   procedure Check (Label, Spec, Body_Text, Main_Text : String) is
      Sources : constant Silver_Application_Units.Bundle :=
        Silver_Application_Units.Pack (Spec, Body_Text, Main_Text);
      Result : constant Silver_Output_Profile.Analysis_Result :=
        Silver_Output_Profile.Analyze (Sources);
   begin
      Ada.Text_IO.Put_Line (Label & ":" & Boolean'Image (Result.Accepted));
      Ada.Text_IO.Put_Line ("import:" & Silver_Output_Profile.Imported_Package (Main_Text));
   end Check;
begin
   Check ("put_line_unqualified", "package Put_Line is pragma SPARK_Mode(On);procedure Noop;end Put_Line;", "package body Put_Line is pragma SPARK_Mode(On);procedure Noop is begin null;end Noop;end Put_Line;", "with Put_Line,Silver_IO;use Silver_IO;procedure Main is pragma SPARK_Mode(On);begin Put_Line(""x"");end Main;");
   Check ("put_line_qualified", "package Put_Line is pragma SPARK_Mode(On);procedure Noop;end Put_Line;", "package body Put_Line is pragma SPARK_Mode(On);procedure Noop is begin null;end Noop;end Put_Line;", "with Put_Line,Silver_IO;use Silver_IO;procedure Main is pragma SPARK_Mode(On);begin Silver_IO.Put_Line(""x"");end Main;");
   Check ("true_literal", "package True is pragma SPARK_Mode(On);procedure Noop;end True;", "package body True is pragma SPARK_Mode(On);procedure Noop is begin null;end Noop;end True;", "with True;procedure Main is pragma SPARK_Mode(On);B:Boolean:=True;begin null;end Main;");
   Check ("false_literal", "package False is pragma SPARK_Mode(On);procedure Noop;end False;", "package body False is pragma SPARK_Mode(On);procedure Noop is begin null;end Noop;end False;", "with False;procedure Main is pragma SPARK_Mode(On);B:Boolean:=False;begin null;end Main;");
end Admission_Probe;
