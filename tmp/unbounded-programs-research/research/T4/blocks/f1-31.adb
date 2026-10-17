with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A31 : Integer range 0 .. 9 := 3;
   B31 : Integer range -5 .. 5 := 0;
   C31 : constant Integer := A31;
   S31 : String := "abc";
begin
   A31 := (9 - A31);
   B31 := (-B31);
   if A31 > C31 then
      S31 := "xyz";
   elsif A31 = 0 then
      B31 := 5;
   else
      S31 := "abc";
   end if;
   for I31 in 1 .. 3 loop
      for J31 in 0 .. I31 loop
         Silver_IO.Put (Integer'Image ((I31 * J31)));
      end loop;
      B31 := (I31 - 3);
   end loop;
   A31 := 7;
   Silver_IO.Put_Line (S31 & Integer'Image (B31));
end Main;
