with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A69 : Integer range 0 .. 9 := 3;
   B69 : Integer range -5 .. 5 := 0;
   C69 : constant Integer := A69;
   S69 : String := "abc";
begin
   A69 := (9 - A69);
   B69 := (-B69);
   if A69 > C69 then
      S69 := "xyz";
   elsif A69 = 0 then
      B69 := 5;
   else
      S69 := "abc";
   end if;
   for I69 in 1 .. 3 loop
      for J69 in 0 .. I69 loop
         Silver_IO.Put (Integer'Image ((I69 * J69)));
      end loop;
      B69 := (I69 - 3);
   end loop;
   A69 := 7;
   Silver_IO.Put_Line (S69 & Integer'Image (B69));
end Main;
