with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A77 : Integer range 0 .. 9 := 3;
   B77 : Integer range -5 .. 5 := 0;
   C77 : constant Integer := A77;
   S77 : String := "abc";
begin
   A77 := (9 - A77);
   B77 := (-B77);
   if A77 > C77 then
      S77 := "xyz";
   elsif A77 = 0 then
      B77 := 5;
   else
      S77 := "abc";
   end if;
   for I77 in 1 .. 3 loop
      for J77 in 0 .. I77 loop
         Silver_IO.Put (Integer'Image ((I77 * J77)));
      end loop;
      B77 := (I77 - 3);
   end loop;
   A77 := 7;
   Silver_IO.Put_Line (S77 & Integer'Image (B77));
end Main;
