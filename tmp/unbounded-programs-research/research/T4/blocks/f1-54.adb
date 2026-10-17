with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A54 : Integer range 0 .. 9 := 3;
   B54 : Integer range -5 .. 5 := 0;
   C54 : constant Integer := A54;
   S54 : String := "abc";
begin
   A54 := (9 - A54);
   B54 := (-B54);
   if A54 > C54 then
      S54 := "xyz";
   elsif A54 = 0 then
      B54 := 5;
   else
      S54 := "abc";
   end if;
   for I54 in 1 .. 3 loop
      for J54 in 0 .. I54 loop
         Silver_IO.Put (Integer'Image ((I54 * J54)));
      end loop;
      B54 := (I54 - 3);
   end loop;
   A54 := 7;
   Silver_IO.Put_Line (S54 & Integer'Image (B54));
end Main;
