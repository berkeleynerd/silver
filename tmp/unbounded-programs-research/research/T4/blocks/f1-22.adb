with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A22 : Integer range 0 .. 9 := 3;
   B22 : Integer range -5 .. 5 := 0;
   C22 : constant Integer := A22;
   S22 : String := "abc";
begin
   A22 := (9 - A22);
   B22 := (-B22);
   if A22 > C22 then
      S22 := "xyz";
   elsif A22 = 0 then
      B22 := 5;
   else
      S22 := "abc";
   end if;
   for I22 in 1 .. 3 loop
      for J22 in 0 .. I22 loop
         Silver_IO.Put (Integer'Image ((I22 * J22)));
      end loop;
      B22 := (I22 - 3);
   end loop;
   A22 := 7;
   Silver_IO.Put_Line (S22 & Integer'Image (B22));
end Main;
