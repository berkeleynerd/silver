with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A7 : Integer range 0 .. 9 := 3;
   B7 : Integer range -5 .. 5 := 0;
   C7 : constant Integer := A7;
   S7 : String := "abc";
begin
   A7 := (9 - A7);
   B7 := (-B7);
   if A7 > C7 then
      S7 := "xyz";
   elsif A7 = 0 then
      B7 := 5;
   else
      S7 := "abc";
   end if;
   for I7 in 1 .. 3 loop
      for J7 in 0 .. I7 loop
         Silver_IO.Put (Integer'Image ((I7 * J7)));
      end loop;
      B7 := (I7 - 3);
   end loop;
   A7 := 7;
   Silver_IO.Put_Line (S7 & Integer'Image (B7));
end Main;
