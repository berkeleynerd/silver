with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A33 : Integer range 0 .. 9 := 3;
   B33 : Integer range -5 .. 5 := 0;
   C33 : constant Integer := A33;
   S33 : String := "abc";
begin
   A33 := (9 - A33);
   B33 := (-B33);
   if A33 > C33 then
      S33 := "xyz";
   elsif A33 = 0 then
      B33 := 5;
   else
      S33 := "abc";
   end if;
   for I33 in 1 .. 3 loop
      for J33 in 0 .. I33 loop
         Silver_IO.Put (Integer'Image ((I33 * J33)));
      end loop;
      B33 := (I33 - 3);
   end loop;
   A33 := 7;
   Silver_IO.Put_Line (S33 & Integer'Image (B33));
end Main;
