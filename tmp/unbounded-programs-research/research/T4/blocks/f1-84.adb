with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A84 : Integer range 0 .. 9 := 3;
   B84 : Integer range -5 .. 5 := 0;
   C84 : constant Integer := A84;
   S84 : String := "abc";
begin
   A84 := (9 - A84);
   B84 := (-B84);
   if A84 > C84 then
      S84 := "xyz";
   elsif A84 = 0 then
      B84 := 5;
   else
      S84 := "abc";
   end if;
   for I84 in 1 .. 3 loop
      for J84 in 0 .. I84 loop
         Silver_IO.Put (Integer'Image ((I84 * J84)));
      end loop;
      B84 := (I84 - 3);
   end loop;
   A84 := 7;
   Silver_IO.Put_Line (S84 & Integer'Image (B84));
end Main;
