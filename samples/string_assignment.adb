with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : String := "Hello";
begin
   Message := "World";
   Silver_IO.Put_Line (Message);
end Main;
