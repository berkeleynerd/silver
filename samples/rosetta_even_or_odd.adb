with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for Number in -3 .. 3 loop
      if (Number rem 2) = 0 then
         Silver_IO.Put_Line (Integer'Image (Number) & ": even");
      else
         Silver_IO.Put_Line (Integer'Image (Number) & ": odd");
      end if;
   end loop;
end Main;
