with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A76 : Integer range 0 .. 9 := 3;
   B76 : Integer range -5 .. 5 := 0;
   C76 : constant Integer := A76;
   S76 : String := "abc";
begin
   A76 := (9 - A76);
   B76 := (-B76);
   if A76 > C76 then
      S76 := "xyz";
   elsif A76 = 0 then
      B76 := 5;
   else
      S76 := "abc";
   end if;
   for I76 in 1 .. 3 loop
      for J76 in 0 .. I76 loop
         Silver_IO.Put (Integer'Image ((I76 * J76)));
      end loop;
      B76 := (I76 - 3);
   end loop;
   A76 := 7;
   Silver_IO.Put_Line (S76 & Integer'Image (B76));
end Main;
