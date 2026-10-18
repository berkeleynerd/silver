-- leadingwith Silver_IO, -- packageSilver_Arguments;
procedure -- noteMain is
   pragma SPARK_Mode (On);
   D : constant String := Silver_Arguments.First_Or_Default ("default");
begin
   if Silver_Arguments.Input_Is_Valid then
      Silver_IO.Put_Line (D);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
