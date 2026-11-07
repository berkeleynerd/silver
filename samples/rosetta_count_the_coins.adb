with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Total : Integer range 0 .. 300 := 0;
   Ways : Integer range 0 .. 1155 := 0;
begin
   for Quarters in 0 .. 4 loop
      for Dimes in 0 .. 10 loop
         for Nickels in 0 .. 20 loop
            Total := (((Quarters * 25) + (Dimes * 10)) + (Nickels * 5));
            -- Remaining cents are pennies: one way per affordable triple.
            -- There are 5 * 11 * 21 triples, so the guard skips none.
            if Total <= 100 and then Ways < 1155 then
               Ways := (Ways + 1);
            end if;
         end loop;
      end loop;
   end loop;
   Silver_IO.Put_Line
      ("Ways to make 100 cents with 25, 10, 5 and 1:" & Integer'Image (Ways));
end Main;
