with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Message : constant String :=
     Silver_Arguments.First_Or_Default ("Hello, world!");
begin
   if Silver_Arguments.Input_Is_Valid then
      Silver_IO.Put_Line (Message);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
