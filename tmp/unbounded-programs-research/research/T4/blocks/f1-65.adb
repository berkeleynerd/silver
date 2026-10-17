with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A65 : Integer range 0 .. 9 := 3;
   B65 : Integer range -5 .. 5 := 0;
   C65 : constant Integer := A65;
   S65 : String := "abc";
begin
   A65 := (9 - A65);
   B65 := (-B65);
   if A65 > C65 then
      S65 := "xyz";
   elsif A65 = 0 then
      B65 := 5;
   else
      S65 := "abc";
   end if;
   for I65 in 1 .. 3 loop
      for J65 in 0 .. I65 loop
         Silver_IO.Put (Integer'Image ((I65 * J65)));
      end loop;
      B65 := (I65 - 3);
   end loop;
   A65 := 7;
   Silver_IO.Put_Line (S65 & Integer'Image (B65));
end Main;
