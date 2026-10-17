with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A80 : Integer range 0 .. 9 := 3;
   B80 : Integer range -5 .. 5 := 0;
   C80 : constant Integer := A80;
   S80 : String := "abc";
begin
   A80 := (9 - A80);
   B80 := (-B80);
   if A80 > C80 then
      S80 := "xyz";
   elsif A80 = 0 then
      B80 := 5;
   else
      S80 := "abc";
   end if;
   for I80 in 1 .. 3 loop
      for J80 in 0 .. I80 loop
         Silver_IO.Put (Integer'Image ((I80 * J80)));
      end loop;
      B80 := (I80 - 3);
   end loop;
   A80 := 7;
   Silver_IO.Put_Line (S80 & Integer'Image (B80));
end Main;
