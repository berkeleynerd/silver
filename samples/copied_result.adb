with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Mode : constant String := Silver_Arguments.First_Or_Default ("brief");
   Ready : constant String := "ready";
   Detailed : constant String := "extra";
   Result : String := Ready;
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Result := Detailed;
      else
         Result := Ready;
      end if;
      Silver_IO.Put_Line
        ("Selected: " & Result & " (choices: " & Ready & ", " & Detailed & ")");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
