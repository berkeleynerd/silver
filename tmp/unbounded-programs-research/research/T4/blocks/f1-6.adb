with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A6 : Integer range 0 .. 9 := 3;
   B6 : Integer range -5 .. 5 := 0;
   C6 : constant Integer := A6;
   S6 : String := "abc";
begin
   A6 := (9 - A6);
   B6 := (-B6);
   if A6 > C6 then
      S6 := "xyz";
   elsif A6 = 0 then
      B6 := 5;
   else
      S6 := "abc";
   end if;
   for I6 in 1 .. 3 loop
      for J6 in 0 .. I6 loop
         Silver_IO.Put (Integer'Image ((I6 * J6)));
      end loop;
      B6 := (I6 - 3);
   end loop;
   A6 := 7;
   Silver_IO.Put_Line (S6 & Integer'Image (B6));
end Main;
