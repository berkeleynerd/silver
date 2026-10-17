with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A90 : Integer range 0 .. 9 := 3;
   B90 : Integer range -5 .. 5 := 0;
   C90 : constant Integer := A90;
   S90 : String := "abc";
begin
   A90 := (9 - A90);
   B90 := (-B90);
   if A90 > C90 then
      S90 := "xyz";
   elsif A90 = 0 then
      B90 := 5;
   else
      S90 := "abc";
   end if;
   for I90 in 1 .. 3 loop
      for J90 in 0 .. I90 loop
         Silver_IO.Put (Integer'Image ((I90 * J90)));
      end loop;
      B90 := (I90 - 3);
   end loop;
   A90 := 7;
   Silver_IO.Put_Line (S90 & Integer'Image (B90));
end Main;
