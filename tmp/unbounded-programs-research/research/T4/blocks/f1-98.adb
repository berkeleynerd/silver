with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A98 : Integer range 0 .. 9 := 3;
   B98 : Integer range -5 .. 5 := 0;
   C98 : constant Integer := A98;
   S98 : String := "abc";
begin
   A98 := (9 - A98);
   B98 := (-B98);
   if A98 > C98 then
      S98 := "xyz";
   elsif A98 = 0 then
      B98 := 5;
   else
      S98 := "abc";
   end if;
   for I98 in 1 .. 3 loop
      for J98 in 0 .. I98 loop
         Silver_IO.Put (Integer'Image ((I98 * J98)));
      end loop;
      B98 := (I98 - 3);
   end loop;
   A98 := 7;
   Silver_IO.Put_Line (S98 & Integer'Image (B98));
end Main;
