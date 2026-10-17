with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A19 : Integer range 0 .. 9 := 3;
   B19 : Integer range -5 .. 5 := 0;
   C19 : constant Integer := A19;
   S19 : String := "abc";
begin
   A19 := (9 - A19);
   B19 := (-B19);
   if A19 > C19 then
      S19 := "xyz";
   elsif A19 = 0 then
      B19 := 5;
   else
      S19 := "abc";
   end if;
   for I19 in 1 .. 3 loop
      for J19 in 0 .. I19 loop
         Silver_IO.Put (Integer'Image ((I19 * J19)));
      end loop;
      B19 := (I19 - 3);
   end loop;
   A19 := 7;
   Silver_IO.Put_Line (S19 & Integer'Image (B19));
end Main;
