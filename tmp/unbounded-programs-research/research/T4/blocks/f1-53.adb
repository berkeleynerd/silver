with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A53 : Integer range 0 .. 9 := 3;
   B53 : Integer range -5 .. 5 := 0;
   C53 : constant Integer := A53;
   S53 : String := "abc";
begin
   A53 := (9 - A53);
   B53 := (-B53);
   if A53 > C53 then
      S53 := "xyz";
   elsif A53 = 0 then
      B53 := 5;
   else
      S53 := "abc";
   end if;
   for I53 in 1 .. 3 loop
      for J53 in 0 .. I53 loop
         Silver_IO.Put (Integer'Image ((I53 * J53)));
      end loop;
      B53 := (I53 - 3);
   end loop;
   A53 := 7;
   Silver_IO.Put_Line (S53 & Integer'Image (B53));
end Main;
