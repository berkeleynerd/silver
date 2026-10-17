with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A73 : Integer range 0 .. 9 := 3;
   B73 : Integer range -5 .. 5 := 0;
   C73 : constant Integer := A73;
   S73 : String := "abc";
begin
   A73 := (9 - A73);
   B73 := (-B73);
   if A73 > C73 then
      S73 := "xyz";
   elsif A73 = 0 then
      B73 := 5;
   else
      S73 := "abc";
   end if;
   for I73 in 1 .. 3 loop
      for J73 in 0 .. I73 loop
         Silver_IO.Put (Integer'Image ((I73 * J73)));
      end loop;
      B73 := (I73 - 3);
   end loop;
   A73 := 7;
   Silver_IO.Put_Line (S73 & Integer'Image (B73));
end Main;
