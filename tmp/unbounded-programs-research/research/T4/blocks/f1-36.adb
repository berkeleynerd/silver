with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A36 : Integer range 0 .. 9 := 3;
   B36 : Integer range -5 .. 5 := 0;
   C36 : constant Integer := A36;
   S36 : String := "abc";
begin
   A36 := (9 - A36);
   B36 := (-B36);
   if A36 > C36 then
      S36 := "xyz";
   elsif A36 = 0 then
      B36 := 5;
   else
      S36 := "abc";
   end if;
   for I36 in 1 .. 3 loop
      for J36 in 0 .. I36 loop
         Silver_IO.Put (Integer'Image ((I36 * J36)));
      end loop;
      B36 := (I36 - 3);
   end loop;
   A36 := 7;
   Silver_IO.Put_Line (S36 & Integer'Image (B36));
end Main;
