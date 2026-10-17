with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A61 : Integer range 0 .. 9 := 3;
   B61 : Integer range -5 .. 5 := 0;
   C61 : constant Integer := A61;
   S61 : String := "abc";
begin
   A61 := (9 - A61);
   B61 := (-B61);
   if A61 > C61 then
      S61 := "xyz";
   elsif A61 = 0 then
      B61 := 5;
   else
      S61 := "abc";
   end if;
   for I61 in 1 .. 3 loop
      for J61 in 0 .. I61 loop
         Silver_IO.Put (Integer'Image ((I61 * J61)));
      end loop;
      B61 := (I61 - 3);
   end loop;
   A61 := 7;
   Silver_IO.Put_Line (S61 & Integer'Image (B61));
end Main;
