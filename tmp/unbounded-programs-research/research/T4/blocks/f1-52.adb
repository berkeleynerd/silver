with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A52 : Integer range 0 .. 9 := 3;
   B52 : Integer range -5 .. 5 := 0;
   C52 : constant Integer := A52;
   S52 : String := "abc";
begin
   A52 := (9 - A52);
   B52 := (-B52);
   if A52 > C52 then
      S52 := "xyz";
   elsif A52 = 0 then
      B52 := 5;
   else
      S52 := "abc";
   end if;
   for I52 in 1 .. 3 loop
      for J52 in 0 .. I52 loop
         Silver_IO.Put (Integer'Image ((I52 * J52)));
      end loop;
      B52 := (I52 - 3);
   end loop;
   A52 := 7;
   Silver_IO.Put_Line (S52 & Integer'Image (B52));
end Main;
