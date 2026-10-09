with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Message : constant String := "Hello, world!";
begin
   Silver_IO.Put_Line (Message);
end Main;
