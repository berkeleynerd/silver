with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A96 : Integer range 0 .. 9 := 3;
   B96 : Integer range -5 .. 5 := 0;
   C96 : constant Integer := A96;
   S96 : String := "abc";
begin
   A96 := (9 - A96);
   B96 := (-B96);
   if A96 > C96 then
      S96 := "xyz";
   elsif A96 = 0 then
      B96 := 5;
   else
      S96 := "abc";
   end if;
   for I96 in 1 .. 3 loop
      for J96 in 0 .. I96 loop
         Silver_IO.Put (Integer'Image ((I96 * J96)));
      end loop;
      B96 := (I96 - 3);
   end loop;
   A96 := 7;
   Silver_IO.Put_Line (S96 & Integer'Image (B96));
end Main;
