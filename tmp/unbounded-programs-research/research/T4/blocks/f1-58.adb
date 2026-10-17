with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A58 : Integer range 0 .. 9 := 3;
   B58 : Integer range -5 .. 5 := 0;
   C58 : constant Integer := A58;
   S58 : String := "abc";
begin
   A58 := (9 - A58);
   B58 := (-B58);
   if A58 > C58 then
      S58 := "xyz";
   elsif A58 = 0 then
      B58 := 5;
   else
      S58 := "abc";
   end if;
   for I58 in 1 .. 3 loop
      for J58 in 0 .. I58 loop
         Silver_IO.Put (Integer'Image ((I58 * J58)));
      end loop;
      B58 := (I58 - 3);
   end loop;
   A58 := 7;
   Silver_IO.Put_Line (S58 & Integer'Image (B58));
end Main;
