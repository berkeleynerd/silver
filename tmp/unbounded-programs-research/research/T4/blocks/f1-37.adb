with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A37 : Integer range 0 .. 9 := 3;
   B37 : Integer range -5 .. 5 := 0;
   C37 : constant Integer := A37;
   S37 : String := "abc";
begin
   A37 := (9 - A37);
   B37 := (-B37);
   if A37 > C37 then
      S37 := "xyz";
   elsif A37 = 0 then
      B37 := 5;
   else
      S37 := "abc";
   end if;
   for I37 in 1 .. 3 loop
      for J37 in 0 .. I37 loop
         Silver_IO.Put (Integer'Image ((I37 * J37)));
      end loop;
      B37 := (I37 - 3);
   end loop;
   A37 := 7;
   Silver_IO.Put_Line (S37 & Integer'Image (B37));
end Main;
