with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A28 : Integer range 0 .. 9 := 3;
   B28 : Integer range -5 .. 5 := 0;
   C28 : constant Integer := A28;
   S28 : String := "abc";
begin
   A28 := (9 - A28);
   B28 := (-B28);
   if A28 > C28 then
      S28 := "xyz";
   elsif A28 = 0 then
      B28 := 5;
   else
      S28 := "abc";
   end if;
   for I28 in 1 .. 3 loop
      for J28 in 0 .. I28 loop
         Silver_IO.Put (Integer'Image ((I28 * J28)));
      end loop;
      B28 := (I28 - 3);
   end loop;
   A28 := 7;
   Silver_IO.Put_Line (S28 & Integer'Image (B28));
end Main;
