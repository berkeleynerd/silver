with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A78 : Integer range 0 .. 9 := 3;
   B78 : Integer range -5 .. 5 := 0;
   C78 : constant Integer := A78;
   S78 : String := "abc";
begin
   A78 := (9 - A78);
   B78 := (-B78);
   if A78 > C78 then
      S78 := "xyz";
   elsif A78 = 0 then
      B78 := 5;
   else
      S78 := "abc";
   end if;
   for I78 in 1 .. 3 loop
      for J78 in 0 .. I78 loop
         Silver_IO.Put (Integer'Image ((I78 * J78)));
      end loop;
      B78 := (I78 - 3);
   end loop;
   A78 := 7;
   Silver_IO.Put_Line (S78 & Integer'Image (B78));
end Main;
