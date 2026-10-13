with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Input : constant String := Silver_Arguments.First_Or_Default ("guest");
   Prefix : constant String := ("Hello" & ", ");
   Status : String := ("wait" & "??");
   Snapshot : constant String := "[" & Status & "]";
begin
   if Silver_Arguments.Input_Is_Valid and then Input'Length <= 2000 then
      if ("" & Input) = ("gu" & "est") then
         Status := ("gu" & "est!");
      else
         Status := ("fr" & "iend");
      end if;
      Silver_IO.Put_Line
        (Prefix & (Input & (" / " & Input)) & ": " & Status & " " & Snapshot);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
