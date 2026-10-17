with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   X : Integer := 0E4097;
begin
   Silver_IO.Put_Line (Integer'Image (X));
end Main;
