with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A81 : Integer range 0 .. 9 := 3;
   B81 : Integer range -5 .. 5 := 0;
   C81 : constant Integer := A81;
   S81 : String := "abc";
begin
   A81 := (9 - A81);
   B81 := (-B81);
   if A81 > C81 then
      S81 := "xyz";
   elsif A81 = 0 then
      B81 := 5;
   else
      S81 := "abc";
   end if;
   for I81 in 1 .. 3 loop
      for J81 in 0 .. I81 loop
         Silver_IO.Put (Integer'Image ((I81 * J81)));
      end loop;
      B81 := (I81 - 3);
   end loop;
   A81 := 7;
   Silver_IO.Put_Line (S81 & Integer'Image (B81));
end Main;
