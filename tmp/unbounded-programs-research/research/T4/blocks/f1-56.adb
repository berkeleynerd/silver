with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A56 : Integer range 0 .. 9 := 3;
   B56 : Integer range -5 .. 5 := 0;
   C56 : constant Integer := A56;
   S56 : String := "abc";
begin
   A56 := (9 - A56);
   B56 := (-B56);
   if A56 > C56 then
      S56 := "xyz";
   elsif A56 = 0 then
      B56 := 5;
   else
      S56 := "abc";
   end if;
   for I56 in 1 .. 3 loop
      for J56 in 0 .. I56 loop
         Silver_IO.Put (Integer'Image ((I56 * J56)));
      end loop;
      B56 := (I56 - 3);
   end loop;
   A56 := 7;
   Silver_IO.Put_Line (S56 & Integer'Image (B56));
end Main;
