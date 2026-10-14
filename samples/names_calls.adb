with Silver_Arguments, Silver_IO;
use Silver_Arguments, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := First_Or_Default (Default => "world");
begin
   if Input_Is_Valid and then Name'Length <= 4088 then
      Put_Line (Item => "Hello, " & Name & "!");
   else
      Reject;
   end if;
end Main;
