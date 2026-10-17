with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A50 : Integer range 0 .. 9 := 3;
   B50 : Integer range -5 .. 5 := 0;
   C50 : constant Integer := A50;
   S50 : String := "abc";
begin
   A50 := (9 - A50);
   B50 := (-B50);
   if A50 > C50 then
      S50 := "xyz";
   elsif A50 = 0 then
      B50 := 5;
   else
      S50 := "abc";
   end if;
   for I50 in 1 .. 3 loop
      for J50 in 0 .. I50 loop
         Silver_IO.Put (Integer'Image ((I50 * J50)));
      end loop;
      B50 := (I50 - 3);
   end loop;
   A50 := 7;
   Silver_IO.Put_Line (S50 & Integer'Image (B50));
end Main;
