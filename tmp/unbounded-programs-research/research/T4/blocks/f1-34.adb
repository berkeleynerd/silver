with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A34 : Integer range 0 .. 9 := 3;
   B34 : Integer range -5 .. 5 := 0;
   C34 : constant Integer := A34;
   S34 : String := "abc";
begin
   A34 := (9 - A34);
   B34 := (-B34);
   if A34 > C34 then
      S34 := "xyz";
   elsif A34 = 0 then
      B34 := 5;
   else
      S34 := "abc";
   end if;
   for I34 in 1 .. 3 loop
      for J34 in 0 .. I34 loop
         Silver_IO.Put (Integer'Image ((I34 * J34)));
      end loop;
      B34 := (I34 - 3);
   end loop;
   A34 := 7;
   Silver_IO.Put_Line (S34 & Integer'Image (B34));
end Main;
