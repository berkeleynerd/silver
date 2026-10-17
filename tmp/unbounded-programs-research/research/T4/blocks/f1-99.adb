with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A99 : Integer range 0 .. 9 := 3;
   B99 : Integer range -5 .. 5 := 0;
   C99 : constant Integer := A99;
   S99 : String := "abc";
begin
   A99 := (9 - A99);
   B99 := (-B99);
   if A99 > C99 then
      S99 := "xyz";
   elsif A99 = 0 then
      B99 := 5;
   else
      S99 := "abc";
   end if;
   for I99 in 1 .. 3 loop
      for J99 in 0 .. I99 loop
         Silver_IO.Put (Integer'Image ((I99 * J99)));
      end loop;
      B99 := (I99 - 3);
   end loop;
   A99 := 7;
   Silver_IO.Put_Line (S99 & Integer'Image (B99));
end Main;
