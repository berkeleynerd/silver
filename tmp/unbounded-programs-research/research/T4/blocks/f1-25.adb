with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A25 : Integer range 0 .. 9 := 3;
   B25 : Integer range -5 .. 5 := 0;
   C25 : constant Integer := A25;
   S25 : String := "abc";
begin
   A25 := (9 - A25);
   B25 := (-B25);
   if A25 > C25 then
      S25 := "xyz";
   elsif A25 = 0 then
      B25 := 5;
   else
      S25 := "abc";
   end if;
   for I25 in 1 .. 3 loop
      for J25 in 0 .. I25 loop
         Silver_IO.Put (Integer'Image ((I25 * J25)));
      end loop;
      B25 := (I25 - 3);
   end loop;
   A25 := 7;
   Silver_IO.Put_Line (S25 & Integer'Image (B25));
end Main;
