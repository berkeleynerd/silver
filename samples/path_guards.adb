with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Input : constant String := Silver_Arguments.First_Or_Default ("guest");
   Work : String := Input;
   Original : constant String := Work;
   Label : constant String := "Hello";
begin
   if not Silver_Arguments.Input_Is_Valid then
      Silver_Arguments.Reject;
   elsif Input'Length = 5 and then Input /= "quiet" then
      Work := Label;
      Silver_IO.Put_Line (Work & ":" & Original);
   elsif Input'Length <= 16#7FF# then
      Silver_IO.Put_Line (Input & Input);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
