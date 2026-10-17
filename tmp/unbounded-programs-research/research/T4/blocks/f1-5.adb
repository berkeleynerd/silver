with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A5 : Integer range 0 .. 9 := 3;
   B5 : Integer range -5 .. 5 := 0;
   C5 : constant Integer := A5;
   S5 : String := "abc";
begin
   A5 := (9 - A5);
   B5 := (-B5);
   if A5 > C5 then
      S5 := "xyz";
   elsif A5 = 0 then
      B5 := 5;
   else
      S5 := "abc";
   end if;
   for I5 in 1 .. 3 loop
      for J5 in 0 .. I5 loop
         Silver_IO.Put (Integer'Image ((I5 * J5)));
      end loop;
      B5 := (I5 - 3);
   end loop;
   A5 := 7;
   Silver_IO.Put_Line (S5 & Integer'Image (B5));
end Main;
