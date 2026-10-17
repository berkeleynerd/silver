with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A94 : Integer range 0 .. 9 := 3;
   B94 : Integer range -5 .. 5 := 0;
   C94 : constant Integer := A94;
   S94 : String := "abc";
begin
   A94 := (9 - A94);
   B94 := (-B94);
   if A94 > C94 then
      S94 := "xyz";
   elsif A94 = 0 then
      B94 := 5;
   else
      S94 := "abc";
   end if;
   for I94 in 1 .. 3 loop
      for J94 in 0 .. I94 loop
         Silver_IO.Put (Integer'Image ((I94 * J94)));
      end loop;
      B94 := (I94 - 3);
   end loop;
   A94 := 7;
   Silver_IO.Put_Line (S94 & Integer'Image (B94));
end Main;
