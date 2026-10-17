with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A51 : Integer range 0 .. 9 := 3;
   B51 : Integer range -5 .. 5 := 0;
   C51 : constant Integer := A51;
   S51 : String := "abc";
begin
   A51 := (9 - A51);
   B51 := (-B51);
   if A51 > C51 then
      S51 := "xyz";
   elsif A51 = 0 then
      B51 := 5;
   else
      S51 := "abc";
   end if;
   for I51 in 1 .. 3 loop
      for J51 in 0 .. I51 loop
         Silver_IO.Put (Integer'Image ((I51 * J51)));
      end loop;
      B51 := (I51 - 3);
   end loop;
   A51 := 7;
   Silver_IO.Put_Line (S51 & Integer'Image (B51));
end Main;
