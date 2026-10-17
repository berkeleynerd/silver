with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A9 : Integer range 0 .. 9 := 3;
   B9 : Integer range -5 .. 5 := 0;
   C9 : constant Integer := A9;
   S9 : String := "abc";
begin
   A9 := (9 - A9);
   B9 := (-B9);
   if A9 > C9 then
      S9 := "xyz";
   elsif A9 = 0 then
      B9 := 5;
   else
      S9 := "abc";
   end if;
   for I9 in 1 .. 3 loop
      for J9 in 0 .. I9 loop
         Silver_IO.Put (Integer'Image ((I9 * J9)));
      end loop;
      B9 := (I9 - 3);
   end loop;
   A9 := 7;
   Silver_IO.Put_Line (S9 & Integer'Image (B9));
end Main;
