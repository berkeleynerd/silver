with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A95 : Integer range 0 .. 9 := 3;
   B95 : Integer range -5 .. 5 := 0;
   C95 : constant Integer := A95;
   S95 : String := "abc";
begin
   A95 := (9 - A95);
   B95 := (-B95);
   if A95 > C95 then
      S95 := "xyz";
   elsif A95 = 0 then
      B95 := 5;
   else
      S95 := "abc";
   end if;
   for I95 in 1 .. 3 loop
      for J95 in 0 .. I95 loop
         Silver_IO.Put (Integer'Image ((I95 * J95)));
      end loop;
      B95 := (I95 - 3);
   end loop;
   A95 := 7;
   Silver_IO.Put_Line (S95 & Integer'Image (B95));
end Main;
