with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A14 : Integer range 0 .. 9 := 3;
   B14 : Integer range -5 .. 5 := 0;
   C14 : constant Integer := A14;
   S14 : String := "abc";
begin
   A14 := (9 - A14);
   B14 := (-B14);
   if A14 > C14 then
      S14 := "xyz";
   elsif A14 = 0 then
      B14 := 5;
   else
      S14 := "abc";
   end if;
   for I14 in 1 .. 3 loop
      for J14 in 0 .. I14 loop
         Silver_IO.Put (Integer'Image ((I14 * J14)));
      end loop;
      B14 := (I14 - 3);
   end loop;
   A14 := 7;
   Silver_IO.Put_Line (S14 & Integer'Image (B14));
end Main;
