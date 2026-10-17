with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A16 : Integer range 0 .. 9 := 3;
   B16 : Integer range -5 .. 5 := 0;
   C16 : constant Integer := A16;
   S16 : String := "abc";
begin
   A16 := (9 - A16);
   B16 := (-B16);
   if A16 > C16 then
      S16 := "xyz";
   elsif A16 = 0 then
      B16 := 5;
   else
      S16 := "abc";
   end if;
   for I16 in 1 .. 3 loop
      for J16 in 0 .. I16 loop
         Silver_IO.Put (Integer'Image ((I16 * J16)));
      end loop;
      B16 := (I16 - 3);
   end loop;
   A16 := 7;
   Silver_IO.Put_Line (S16 & Integer'Image (B16));
end Main;
