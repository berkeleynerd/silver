with Ada.Text_IO;
with Ada.Command_Line;
with Silver_Library_Reports;
procedure Library_Reports_Probe is
   Report : constant String := Ada.Text_IO.Get_Line;
   Kind : constant Silver_Library_Reports.Report_Kind :=
     (if Ada.Command_Line.Argument (1) = "body"
      then Silver_Library_Reports.Library_Body
      elsif Ada.Command_Line.Argument (1) = "arguments"
      then Silver_Library_Reports.Arguments_Body
      elsif Ada.Command_Line.Argument (1) = "runtime"
      then Silver_Library_Reports.Runtime_Interface
      else Silver_Library_Reports.Imported_Interface);
begin
   if (if Ada.Command_Line.Argument (1) = "main"
       then Silver_Library_Reports.Complete_Application_Proof (Report)
       else Silver_Library_Reports.Complete_Runtime_Proof (Report, Kind)) then
      Ada.Text_IO.Put_Line ("accepted");
   else
      Ada.Text_IO.Put_Line ("rejected");
   end if;
end Library_Reports_Probe;
