with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A67 : Integer range 0 .. 9 := 3;
   B67 : Integer range -5 .. 5 := 0;
   C67 : constant Integer := A67;
   S67 : String := "abc";
begin
   A67 := (9 - A67);
   B67 := (-B67);
   if A67 > C67 then
      S67 := "xyz";
   elsif A67 = 0 then
      B67 := 5;
   else
      S67 := "abc";
   end if;
   for I67 in 1 .. 3 loop
      for J67 in 0 .. I67 loop
         Silver_IO.Put (Integer'Image ((I67 * J67)));
      end loop;
      B67 := (I67 - 3);
   end loop;
   A67 := 7;
   Silver_IO.Put_Line (S67 & Integer'Image (B67));
end Main;
