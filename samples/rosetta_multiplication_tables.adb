with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Product : Integer range 1 .. 144 := 1;
begin
   Silver_IO.Put ("    ");
   for Column in 1 .. 12 loop
      if Column < 10 then
         Silver_IO.Put ("  ");
      else
         Silver_IO.Put (" ");
      end if;
      Silver_IO.Put (Integer'Image (Column));
   end loop;
   Silver_IO.Put_Line ("");
   for Row in 1 .. 12 loop
      if Row < 10 then
         Silver_IO.Put ("  ");
      else
         Silver_IO.Put (" ");
      end if;
      Silver_IO.Put (Integer'Image (Row));
      for Column in 1 .. 12 loop
         if Column < Row then
            Silver_IO.Put ("    ");
         else
            Product := (Row * Column);
            if Product < 10 then
               Silver_IO.Put ("  ");
            elsif Product < 100 then
               Silver_IO.Put (" ");
            end if;
            Silver_IO.Put (Integer'Image (Product));
         end if;
      end loop;
      Silver_IO.Put_Line ("");
   end loop;
end Main;
