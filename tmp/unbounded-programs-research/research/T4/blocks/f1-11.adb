with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A11 : Integer range 0 .. 9 := 3;
   B11 : Integer range -5 .. 5 := 0;
   C11 : constant Integer := A11;
   S11 : String := "abc";
begin
   A11 := (9 - A11);
   B11 := (-B11);
   if A11 > C11 then
      S11 := "xyz";
   elsif A11 = 0 then
      B11 := 5;
   else
      S11 := "abc";
   end if;
   for I11 in 1 .. 3 loop
      for J11 in 0 .. I11 loop
         Silver_IO.Put (Integer'Image ((I11 * J11)));
      end loop;
      B11 := (I11 - 3);
   end loop;
   A11 := 7;
   Silver_IO.Put_Line (S11 & Integer'Image (B11));
end Main;
