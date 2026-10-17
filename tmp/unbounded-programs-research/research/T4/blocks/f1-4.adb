with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A4 : Integer range 0 .. 9 := 3;
   B4 : Integer range -5 .. 5 := 0;
   C4 : constant Integer := A4;
   S4 : String := "abc";
begin
   A4 := (9 - A4);
   B4 := (-B4);
   if A4 > C4 then
      S4 := "xyz";
   elsif A4 = 0 then
      B4 := 5;
   else
      S4 := "abc";
   end if;
   for I4 in 1 .. 3 loop
      for J4 in 0 .. I4 loop
         Silver_IO.Put (Integer'Image ((I4 * J4)));
      end loop;
      B4 := (I4 - 3);
   end loop;
   A4 := 7;
   Silver_IO.Put_Line (S4 & Integer'Image (B4));
end Main;
