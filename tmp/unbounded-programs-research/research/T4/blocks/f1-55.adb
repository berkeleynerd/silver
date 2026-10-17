with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A55 : Integer range 0 .. 9 := 3;
   B55 : Integer range -5 .. 5 := 0;
   C55 : constant Integer := A55;
   S55 : String := "abc";
begin
   A55 := (9 - A55);
   B55 := (-B55);
   if A55 > C55 then
      S55 := "xyz";
   elsif A55 = 0 then
      B55 := 5;
   else
      S55 := "abc";
   end if;
   for I55 in 1 .. 3 loop
      for J55 in 0 .. I55 loop
         Silver_IO.Put (Integer'Image ((I55 * J55)));
      end loop;
      B55 := (I55 - 3);
   end loop;
   A55 := 7;
   Silver_IO.Put_Line (S55 & Integer'Image (B55));
end Main;
