with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A40 : Integer range 0 .. 9 := 3;
   B40 : Integer range -5 .. 5 := 0;
   C40 : constant Integer := A40;
   S40 : String := "abc";
begin
   A40 := (9 - A40);
   B40 := (-B40);
   if A40 > C40 then
      S40 := "xyz";
   elsif A40 = 0 then
      B40 := 5;
   else
      S40 := "abc";
   end if;
   for I40 in 1 .. 3 loop
      for J40 in 0 .. I40 loop
         Silver_IO.Put (Integer'Image ((I40 * J40)));
      end loop;
      B40 := (I40 - 3);
   end loop;
   A40 := 7;
   Silver_IO.Put_Line (S40 & Integer'Image (B40));
end Main;
