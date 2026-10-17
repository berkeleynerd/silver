with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A41 : Integer range 0 .. 9 := 3;
   B41 : Integer range -5 .. 5 := 0;
   C41 : constant Integer := A41;
   S41 : String := "abc";
begin
   A41 := (9 - A41);
   B41 := (-B41);
   if A41 > C41 then
      S41 := "xyz";
   elsif A41 = 0 then
      B41 := 5;
   else
      S41 := "abc";
   end if;
   for I41 in 1 .. 3 loop
      for J41 in 0 .. I41 loop
         Silver_IO.Put (Integer'Image ((I41 * J41)));
      end loop;
      B41 := (I41 - 3);
   end loop;
   A41 := 7;
   Silver_IO.Put_Line (S41 & Integer'Image (B41));
end Main;
