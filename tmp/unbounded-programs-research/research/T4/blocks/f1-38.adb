with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A38 : Integer range 0 .. 9 := 3;
   B38 : Integer range -5 .. 5 := 0;
   C38 : constant Integer := A38;
   S38 : String := "abc";
begin
   A38 := (9 - A38);
   B38 := (-B38);
   if A38 > C38 then
      S38 := "xyz";
   elsif A38 = 0 then
      B38 := 5;
   else
      S38 := "abc";
   end if;
   for I38 in 1 .. 3 loop
      for J38 in 0 .. I38 loop
         Silver_IO.Put (Integer'Image ((I38 * J38)));
      end loop;
      B38 := (I38 - 3);
   end loop;
   A38 := 7;
   Silver_IO.Put_Line (S38 & Integer'Image (B38));
end Main;
