with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A85 : Integer range 0 .. 9 := 3;
   B85 : Integer range -5 .. 5 := 0;
   C85 : constant Integer := A85;
   S85 : String := "abc";
begin
   A85 := (9 - A85);
   B85 := (-B85);
   if A85 > C85 then
      S85 := "xyz";
   elsif A85 = 0 then
      B85 := 5;
   else
      S85 := "abc";
   end if;
   for I85 in 1 .. 3 loop
      for J85 in 0 .. I85 loop
         Silver_IO.Put (Integer'Image ((I85 * J85)));
      end loop;
      B85 := (I85 - 3);
   end loop;
   A85 := 7;
   Silver_IO.Put_Line (S85 & Integer'Image (B85));
end Main;
