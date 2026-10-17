with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A92 : Integer range 0 .. 9 := 3;
   B92 : Integer range -5 .. 5 := 0;
   C92 : constant Integer := A92;
   S92 : String := "abc";
begin
   A92 := (9 - A92);
   B92 := (-B92);
   if A92 > C92 then
      S92 := "xyz";
   elsif A92 = 0 then
      B92 := 5;
   else
      S92 := "abc";
   end if;
   for I92 in 1 .. 3 loop
      for J92 in 0 .. I92 loop
         Silver_IO.Put (Integer'Image ((I92 * J92)));
      end loop;
      B92 := (I92 - 3);
   end loop;
   A92 := 7;
   Silver_IO.Put_Line (S92 & Integer'Image (B92));
end Main;
