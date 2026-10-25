with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for I in 1 .. 10 loop
      Silver_IO.Put (Integer'Image (I));
      if I < 10 then
         Silver_IO.Put (",");
      end if;
   end loop;
   Silver_IO.Put_Line ("");
end Main;
