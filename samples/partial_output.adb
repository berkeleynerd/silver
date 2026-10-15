with Silver_IO;
with Silver_Arguments;
use Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid then
      Put ("Hello, ");
      Put (Item => Name);
      Put_Line ("!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
