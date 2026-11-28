with Ada.Text_IO;
with Ada.Text_IO.Text_Streams;
with Ada.Streams;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Silver_Library_Reports;
with Silver_Output_Profile;
with Silver_Application_Units;
with Silver_Application_Report_Metadata;
procedure Library_Reports_Probe is
   Procedure_Source : constant String :=
     "with Silver_IO;procedure Main is pragma SPARK_Mode(On);" &
     "function Id(X:in Integer)return Integer is begin return X;end Id;" &
     "procedure Set_Value(Value:out Integer;Flag:out Boolean;Carry:in out Integer;Seed:in Integer)is " &
     "begin Value:=0;Flag:=False;Carry:=Value;end Set_Value;" &
     "procedure Reset(Value:out Integer)is begin Value:=0;end Reset;" &
     "procedure Step(Carry:in out Integer)is begin null;end Step;" &
     "begin null;end Main;";
   --  Preserve complete multiline producer bytes, and avoid recursive line
   --  input stack growth for large fixtures.
   function Read_Report return Ada.Strings.Unbounded.Unbounded_String is
      use type Ada.Streams.Stream_Element_Offset;
      Stream : constant Ada.Text_IO.Text_Streams.Stream_Access :=
        Ada.Text_IO.Text_Streams.Stream (Ada.Text_IO.Standard_Input);
      Bytes : Ada.Streams.Stream_Element_Array (1 .. 8_192);
      Last : Ada.Streams.Stream_Element_Offset;
      Block : String (1 .. 8_192);
      Result : Ada.Strings.Unbounded.Unbounded_String;
   begin
      loop
         Ada.Streams.Read (Stream.all, Bytes, Last);
         for I in 1 .. Last loop
            Block (Natural (I)) := Character'Val (Bytes (I));
         end loop;
         Ada.Strings.Unbounded.Append (Result, Block (1 .. Natural (Last)));
         exit when Last < Bytes'Last;
      end loop;
      return Result;
   end Read_Report;
   Input : constant Ada.Strings.Unbounded.Unbounded_String := Read_Report;
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
   if Ada.Command_Line.Argument (1) = "package-main"
     or else Ada.Command_Line.Argument (1) = "package-body"
   then
      pragma Assert (Ada.Command_Line.Argument_Count = 4);
      pragma Assert (Silver_Application_Units.Fits
        (Ada.Command_Line.Argument (2), Ada.Command_Line.Argument (3), Ada.Command_Line.Argument (4)));
      declare
         package Units renames Silver_Application_Units;
         package Metadata renames Silver_Application_Report_Metadata;
         Sources : constant Units.Bundle := Units.Pack
           (Ada.Command_Line.Argument (2), Ada.Command_Line.Argument (3), Ada.Command_Line.Argument (4));
         Analysis : constant Silver_Output_Profile.Analysis_Result :=
           Silver_Output_Profile.Analyze (Sources);
         Package_Report : constant Boolean := Ada.Command_Line.Argument (1) = "package-body";
         Assigned : constant Boolean :=
           (if Package_Report then Analysis.Package_Info.Assigned else Analysis.Uses_Assignment);
         Policy : constant Silver_Library_Reports.Application_Kind :=
           (if not Package_Report and then Analysis.Uses_Arguments then
              (if Assigned then Silver_Library_Reports.Selected_Output
               else Silver_Library_Reports.Argument_Output)
            elsif Assigned then Silver_Library_Reports.Assigned_Output
            else Silver_Library_Reports.Static_Output);
      begin
         pragma Assert (Analysis.Accepted);
         Ada.Text_IO.Put_Line
           (if Silver_Library_Reports.Complete_Application_Proof
             (Report, Policy, Sources.Pool (1 .. Sources.Used),
              (if Package_Report then Metadata.Owned_Functions (Analysis.Package_Info)
               else Analysis.Main_Functions),
              (if Package_Report then Metadata.Owned_Procedures (Analysis.Package_Info)
               else Analysis.Main_Procedures),
              (if Package_Report then Metadata.For_Package (Analysis.Package_Info)
               else Metadata.For_Main (Analysis.Package_Info)))
            then "accepted" else "rejected");
      end;
      return;
   end if;
   if Ada.Command_Line.Argument (1) = "procedures"
     or else Ada.Command_Line.Argument (1) = "procedures-static"
     or else Ada.Command_Line.Argument (1) = "procedures-argument"
     or else Ada.Command_Line.Argument (1) = "procedures-selected"
   then
      declare
         Source : constant String :=
           (if Ada.Command_Line.Argument_Count = 2 then Ada.Command_Line.Argument (2) else Procedure_Source);
         Policy : constant Silver_Library_Reports.Application_Kind :=
           (if Ada.Command_Line.Argument (1) = "procedures-static" then Silver_Library_Reports.Static_Output
            elsif Ada.Command_Line.Argument (1) = "procedures-argument" then Silver_Library_Reports.Argument_Output
            elsif Ada.Command_Line.Argument (1) = "procedures-selected" then Silver_Library_Reports.Selected_Output
            else Silver_Library_Reports.Assigned_Output);
      begin
         pragma Assert (Silver_Output_Profile.Accepts (Source));
         Ada.Text_IO.Put_Line
           (if Silver_Library_Reports.Complete_Application_Proof
              (Report, Policy, Source => Source,
               Functions => Silver_Output_Profile.Local_Functions (Source),
               Procedures => Silver_Output_Profile.Local_Procedures (Source))
            then "accepted" else "rejected");
      end;
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
