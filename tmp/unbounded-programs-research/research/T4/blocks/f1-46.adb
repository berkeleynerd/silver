with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A46 : Integer range 0 .. 9 := 3;
   B46 : Integer range -5 .. 5 := 0;
   C46 : constant Integer := A46;
   S46 : String := "abc";
begin
   A46 := (9 - A46);
   B46 := (-B46);
   if A46 > C46 then
      S46 := "xyz";
   elsif A46 = 0 then
      B46 := 5;
   else
      S46 := "abc";
   end if;
   for I46 in 1 .. 3 loop
      for J46 in 0 .. I46 loop
         Silver_IO.Put (Integer'Image ((I46 * J46)));
      end loop;
      B46 := (I46 - 3);
   end loop;
   A46 := 7;
   Silver_IO.Put_Line (S46 & Integer'Image (B46));
end Main;
