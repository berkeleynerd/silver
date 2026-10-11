with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Mode : constant String := Silver_Arguments.First_Or_Default ("brief");
   Result : String := "ready";
begin
   if Silver_Arguments.Input_Is_Valid and then Mode'Length <= 4074 then
      if Mode = "verbose" then
         Result := "extra";
      else
         Result := "ready";
      end if;
      Silver_IO.Put_Line ("Mode: " & Mode & " / " & Result & " / " & Result);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
