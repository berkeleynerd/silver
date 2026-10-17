with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A66 : Integer range 0 .. 9 := 3;
   B66 : Integer range -5 .. 5 := 0;
   C66 : constant Integer := A66;
   S66 : String := "abc";
begin
   A66 := (9 - A66);
   B66 := (-B66);
   if A66 > C66 then
      S66 := "xyz";
   elsif A66 = 0 then
      B66 := 5;
   else
      S66 := "abc";
   end if;
   for I66 in 1 .. 3 loop
      for J66 in 0 .. I66 loop
         Silver_IO.Put (Integer'Image ((I66 * J66)));
      end loop;
      B66 := (I66 - 3);
   end loop;
   A66 := 7;
   Silver_IO.Put_Line (S66 & Integer'Image (B66));
end Main;
