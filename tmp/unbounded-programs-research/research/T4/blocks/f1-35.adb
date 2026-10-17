with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A35 : Integer range 0 .. 9 := 3;
   B35 : Integer range -5 .. 5 := 0;
   C35 : constant Integer := A35;
   S35 : String := "abc";
begin
   A35 := (9 - A35);
   B35 := (-B35);
   if A35 > C35 then
      S35 := "xyz";
   elsif A35 = 0 then
      B35 := 5;
   else
      S35 := "abc";
   end if;
   for I35 in 1 .. 3 loop
      for J35 in 0 .. I35 loop
         Silver_IO.Put (Integer'Image ((I35 * J35)));
      end loop;
      B35 := (I35 - 3);
   end loop;
   A35 := 7;
   Silver_IO.Put_Line (S35 & Integer'Image (B35));
end Main;
