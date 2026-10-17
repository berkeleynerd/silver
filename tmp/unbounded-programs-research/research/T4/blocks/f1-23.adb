with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A23 : Integer range 0 .. 9 := 3;
   B23 : Integer range -5 .. 5 := 0;
   C23 : constant Integer := A23;
   S23 : String := "abc";
begin
   A23 := (9 - A23);
   B23 := (-B23);
   if A23 > C23 then
      S23 := "xyz";
   elsif A23 = 0 then
      B23 := 5;
   else
      S23 := "abc";
   end if;
   for I23 in 1 .. 3 loop
      for J23 in 0 .. I23 loop
         Silver_IO.Put (Integer'Image ((I23 * J23)));
      end loop;
      B23 := (I23 - 3);
   end loop;
   A23 := 7;
   Silver_IO.Put_Line (S23 & Integer'Image (B23));
end Main;
