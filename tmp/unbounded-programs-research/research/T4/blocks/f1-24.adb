with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A24 : Integer range 0 .. 9 := 3;
   B24 : Integer range -5 .. 5 := 0;
   C24 : constant Integer := A24;
   S24 : String := "abc";
begin
   A24 := (9 - A24);
   B24 := (-B24);
   if A24 > C24 then
      S24 := "xyz";
   elsif A24 = 0 then
      B24 := 5;
   else
      S24 := "abc";
   end if;
   for I24 in 1 .. 3 loop
      for J24 in 0 .. I24 loop
         Silver_IO.Put (Integer'Image ((I24 * J24)));
      end loop;
      B24 := (I24 - 3);
   end loop;
   A24 := 7;
   Silver_IO.Put_Line (S24 & Integer'Image (B24));
end Main;
