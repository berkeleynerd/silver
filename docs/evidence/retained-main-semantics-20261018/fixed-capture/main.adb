with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   S : constant String := Silver_Arguments.First_Or_Default ("x");
begin
   if S = "x" then
      null;
   else
      null;
   end if;
end Main;
