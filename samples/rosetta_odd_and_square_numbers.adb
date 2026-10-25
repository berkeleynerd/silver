with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- All positive square roots of odd squares above 99 and below 1000.
begin
   for I in 11 .. 31 loop
      if (I mod 2) /= 0 then
         Silver_IO.Put (Integer'Image ((I * I)));
      end if;
   end loop;
   Silver_IO.Put_Line ("");
end Main;
