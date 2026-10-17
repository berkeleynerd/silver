with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A13 : Integer range 0 .. 9 := 3;
   B13 : Integer range -5 .. 5 := 0;
   C13 : constant Integer := A13;
   S13 : String := "abc";
begin
   A13 := (9 - A13);
   B13 := (-B13);
   if A13 > C13 then
      S13 := "xyz";
   elsif A13 = 0 then
      B13 := 5;
   else
      S13 := "abc";
   end if;
   for I13 in 1 .. 3 loop
      for J13 in 0 .. I13 loop
         Silver_IO.Put (Integer'Image ((I13 * J13)));
      end loop;
      B13 := (I13 - 3);
   end loop;
   A13 := 7;
   Silver_IO.Put_Line (S13 & Integer'Image (B13));
end Main;
