with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A20 : Integer range 0 .. 9 := 3;
   B20 : Integer range -5 .. 5 := 0;
   C20 : constant Integer := A20;
   S20 : String := "abc";
begin
   A20 := (9 - A20);
   B20 := (-B20);
   if A20 > C20 then
      S20 := "xyz";
   elsif A20 = 0 then
      B20 := 5;
   else
      S20 := "abc";
   end if;
   for I20 in 1 .. 3 loop
      for J20 in 0 .. I20 loop
         Silver_IO.Put (Integer'Image ((I20 * J20)));
      end loop;
      B20 := (I20 - 3);
   end loop;
   A20 := 7;
   Silver_IO.Put_Line (S20 & Integer'Image (B20));
end Main;
