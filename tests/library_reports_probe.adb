with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Silver_Library_Reports;
with Silver_Output_Profile;
procedure Library_Reports_Probe is
   Procedure_Source : constant String :=
     "procedure Main is pragma SPARK_Mode(On);" &
     "function Id(X:in Integer)return Integer is begin return X;end Id;" &
     "procedure Set_Value(Value:out Integer;Flag:out Boolean;Carry:in out Integer)is " &
     "begin Value:=0;Flag:=False;Carry:=Value;end Set_Value;" &
     "procedure Reset(Value:out Integer)is begin Value:=0;end Reset;" &
     "procedure Step(Carry:in out Integer)is begin null;end Step;" &
     "begin null;end Main;";
   --  Avoid Ada.Text_IO.Get_Line's recursive stack growth for large fixtures.
   Input : constant Ada.Strings.Unbounded.Unbounded_String :=
     Ada.Strings.Unbounded.Text_IO.Get_Line;
   Report : constant String := Ada.Strings.Unbounded.To_String (Input);
   Kind : constant Silver_Library_Reports.Report_Kind :=
     (if Ada.Command_Line.Argument (1) = "body"
      then Silver_Library_Reports.Library_Body
      elsif Ada.Command_Line.Argument (1) = "arguments"
      then Silver_Library_Reports.Arguments_Body
      elsif Ada.Command_Line.Argument (1) = "runtime"
      then Silver_Library_Reports.Runtime_Interface
      else Silver_Library_Reports.Imported_Interface);
   function Accepted (Text : String) return Boolean is
     (Silver_Library_Reports.Complete_Application_Proof
        (Text, Silver_Library_Reports.Static_Output));
begin
   if Ada.Command_Line.Argument (1) = "procedures" then
      pragma Assert (Silver_Output_Profile.Accepts (Procedure_Source));
      Ada.Text_IO.Put_Line
        (if Silver_Library_Reports.Complete_Application_Proof
           (Report, Silver_Library_Reports.Assigned_Output,
            Source => Procedure_Source,
            Functions => Silver_Output_Profile.Local_Functions (Procedure_Source),
            Procedures => Silver_Output_Profile.Local_Procedures (Procedure_Source))
         then "accepted" else "rejected");
      return;
   end if;
   if Ada.Command_Line.Argument (1) = "rebased" then
      declare
         Rebased : constant String (37 .. 36 + Report'Length) := Report;
      begin
         Ada.Text_IO.Put_Line (if Accepted (Rebased) then "accepted" else "rejected");
      end;
      return;
   end if;
   if (if Ada.Command_Line.Argument (1) = "main"
       then Silver_Library_Reports.Complete_Application_Proof (Report)
       elsif Ada.Command_Line.Argument (1) = "static"
       then Silver_Library_Reports.Complete_Application_Proof
         (Report, Silver_Library_Reports.Static_Output)
       elsif Ada.Command_Line.Argument (1) = "assignment"
       then Silver_Library_Reports.Complete_Application_Proof
         (Report, Silver_Library_Reports.Assigned_Output)
       elsif Ada.Command_Line.Argument (1) = "selected"
       then Silver_Library_Reports.Complete_Application_Proof
         (Report, Silver_Library_Reports.Selected_Output)
       else Silver_Library_Reports.Complete_Runtime_Proof (Report, Kind)) then
      Ada.Text_IO.Put_Line ("accepted");
   else
      Ada.Text_IO.Put_Line ("rejected");
   end if;
end Library_Reports_Probe;
