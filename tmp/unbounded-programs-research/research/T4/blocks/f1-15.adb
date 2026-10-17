with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A15 : Integer range 0 .. 9 := 3;
   B15 : Integer range -5 .. 5 := 0;
   C15 : constant Integer := A15;
   S15 : String := "abc";
begin
   A15 := (9 - A15);
   B15 := (-B15);
   if A15 > C15 then
      S15 := "xyz";
   elsif A15 = 0 then
      B15 := 5;
   else
      S15 := "abc";
   end if;
   for I15 in 1 .. 3 loop
      for J15 in 0 .. I15 loop
         Silver_IO.Put (Integer'Image ((I15 * J15)));
      end loop;
      B15 := (I15 - 3);
   end loop;
   A15 := 7;
   Silver_IO.Put_Line (S15 & Integer'Image (B15));
end Main;
