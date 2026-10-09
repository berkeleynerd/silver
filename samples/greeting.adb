with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := "world";
begin
   Silver_IO.Put_Line ("Hello, " & Name & "!");
end Main;
