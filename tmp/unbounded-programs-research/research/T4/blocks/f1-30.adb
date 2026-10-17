with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A30 : Integer range 0 .. 9 := 3;
   B30 : Integer range -5 .. 5 := 0;
   C30 : constant Integer := A30;
   S30 : String := "abc";
begin
   A30 := (9 - A30);
   B30 := (-B30);
   if A30 > C30 then
      S30 := "xyz";
   elsif A30 = 0 then
      B30 := 5;
   else
      S30 := "abc";
   end if;
   for I30 in 1 .. 3 loop
      for J30 in 0 .. I30 loop
         Silver_IO.Put (Integer'Image ((I30 * J30)));
      end loop;
      B30 := (I30 - 3);
   end loop;
   A30 := 7;
   Silver_IO.Put_Line (S30 & Integer'Image (B30));
end Main;
