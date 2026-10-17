with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A2 : Integer range 0 .. 9 := 3;
   B2 : Integer range -5 .. 5 := 0;
   C2 : constant Integer := A2;
   S2 : String := "abc";
begin
   A2 := (9 - A2);
   B2 := (-B2);
   if A2 > C2 then
      S2 := "xyz";
   elsif A2 = 0 then
      B2 := 5;
   else
      S2 := "abc";
   end if;
   for I2 in 1 .. 3 loop
      for J2 in 0 .. I2 loop
         Silver_IO.Put (Integer'Image ((I2 * J2)));
      end loop;
      B2 := (I2 - 3);
   end loop;
   A2 := 7;
   Silver_IO.Put_Line (S2 & Integer'Image (B2));
end Main;
