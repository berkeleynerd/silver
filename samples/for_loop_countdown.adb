with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for I in reverse 0 .. 10 loop
      Silver_IO.Put_Line (Integer'Image (I));
   end loop;
end Main;
