with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A12 : Integer range 0 .. 9 := 3;
   B12 : Integer range -5 .. 5 := 0;
   C12 : constant Integer := A12;
   S12 : String := "abc";
begin
   A12 := (9 - A12);
   B12 := (-B12);
   if A12 > C12 then
      S12 := "xyz";
   elsif A12 = 0 then
      B12 := 5;
   else
      S12 := "abc";
   end if;
   for I12 in 1 .. 3 loop
      for J12 in 0 .. I12 loop
         Silver_IO.Put (Integer'Image ((I12 * J12)));
      end loop;
      B12 := (I12 - 3);
   end loop;
   A12 := 7;
   Silver_IO.Put_Line (S12 & Integer'Image (B12));
end Main;
