with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A26 : Integer range 0 .. 9 := 3;
   B26 : Integer range -5 .. 5 := 0;
   C26 : constant Integer := A26;
   S26 : String := "abc";
begin
   A26 := (9 - A26);
   B26 := (-B26);
   if A26 > C26 then
      S26 := "xyz";
   elsif A26 = 0 then
      B26 := 5;
   else
      S26 := "abc";
   end if;
   for I26 in 1 .. 3 loop
      for J26 in 0 .. I26 loop
         Silver_IO.Put (Integer'Image ((I26 * J26)));
      end loop;
      B26 := (I26 - 3);
   end loop;
   A26 := 7;
   Silver_IO.Put_Line (S26 & Integer'Image (B26));
end Main;
