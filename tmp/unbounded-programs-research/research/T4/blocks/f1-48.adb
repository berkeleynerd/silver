with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A48 : Integer range 0 .. 9 := 3;
   B48 : Integer range -5 .. 5 := 0;
   C48 : constant Integer := A48;
   S48 : String := "abc";
begin
   A48 := (9 - A48);
   B48 := (-B48);
   if A48 > C48 then
      S48 := "xyz";
   elsif A48 = 0 then
      B48 := 5;
   else
      S48 := "abc";
   end if;
   for I48 in 1 .. 3 loop
      for J48 in 0 .. I48 loop
         Silver_IO.Put (Integer'Image ((I48 * J48)));
      end loop;
      B48 := (I48 - 3);
   end loop;
   A48 := 7;
   Silver_IO.Put_Line (S48 & Integer'Image (B48));
end Main;
