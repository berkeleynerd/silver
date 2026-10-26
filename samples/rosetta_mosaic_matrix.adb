with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Side : constant Integer := 8;
begin
   for Row in 1 .. Side loop
      for Col in 1 .. Side loop
         if ((Row + Col) mod 2) = 0 then
            Silver_IO.Put ("1 ");
         else
            Silver_IO.Put (". ");
         end if;
      end loop;
      Silver_IO.Put_Line ("");
   end loop;
end Main;
