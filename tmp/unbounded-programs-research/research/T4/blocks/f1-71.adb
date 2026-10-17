with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A71 : Integer range 0 .. 9 := 3;
   B71 : Integer range -5 .. 5 := 0;
   C71 : constant Integer := A71;
   S71 : String := "abc";
begin
   A71 := (9 - A71);
   B71 := (-B71);
   if A71 > C71 then
      S71 := "xyz";
   elsif A71 = 0 then
      B71 := 5;
   else
      S71 := "abc";
   end if;
   for I71 in 1 .. 3 loop
      for J71 in 0 .. I71 loop
         Silver_IO.Put (Integer'Image ((I71 * J71)));
      end loop;
      B71 := (I71 - 3);
   end loop;
   A71 := 7;
   Silver_IO.Put_Line (S71 & Integer'Image (B71));
end Main;
