with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A10 : Integer range 0 .. 9 := 3;
   B10 : Integer range -5 .. 5 := 0;
   C10 : constant Integer := A10;
   S10 : String := "abc";
begin
   A10 := (9 - A10);
   B10 := (-B10);
   if A10 > C10 then
      S10 := "xyz";
   elsif A10 = 0 then
      B10 := 5;
   else
      S10 := "abc";
   end if;
   for I10 in 1 .. 3 loop
      for J10 in 0 .. I10 loop
         Silver_IO.Put (Integer'Image ((I10 * J10)));
      end loop;
      B10 := (I10 - 3);
   end loop;
   A10 := 7;
   Silver_IO.Put_Line (S10 & Integer'Image (B10));
end Main;
