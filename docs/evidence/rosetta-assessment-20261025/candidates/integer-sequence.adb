with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for Value in 1 .. 2147483647 loop
      Silver_IO.Put_Line (Integer'Image (Value));
   end loop;
end Main;
