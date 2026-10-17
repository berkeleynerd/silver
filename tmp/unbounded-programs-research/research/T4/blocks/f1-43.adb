with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A43 : Integer range 0 .. 9 := 3;
   B43 : Integer range -5 .. 5 := 0;
   C43 : constant Integer := A43;
   S43 : String := "abc";
begin
   A43 := (9 - A43);
   B43 := (-B43);
   if A43 > C43 then
      S43 := "xyz";
   elsif A43 = 0 then
      B43 := 5;
   else
      S43 := "abc";
   end if;
   for I43 in 1 .. 3 loop
      for J43 in 0 .. I43 loop
         Silver_IO.Put (Integer'Image ((I43 * J43)));
      end loop;
      B43 := (I43 - 3);
   end loop;
   A43 := 7;
   Silver_IO.Put_Line (S43 & Integer'Image (B43));
end Main;
