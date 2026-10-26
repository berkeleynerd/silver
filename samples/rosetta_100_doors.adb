with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Visits : Integer range 0 .. 100 := 0;
begin
   for Door in 1 .. 100 loop
      Visits := 0;
      for Pass in 1 .. 100 loop
         if (Door mod Pass) = 0 and then Visits < 100 then
            Visits := (Visits + 1);
         end if;
      end loop;
      if (Visits mod 2) = 1 then
         Silver_IO.Put_Line (Integer'Image (Door) & " is open");
      else
         Silver_IO.Put_Line (Integer'Image (Door) & " is closed");
      end if;
   end loop;
end Main;
