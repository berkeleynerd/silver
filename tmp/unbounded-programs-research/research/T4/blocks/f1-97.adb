with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A97 : Integer range 0 .. 9 := 3;
   B97 : Integer range -5 .. 5 := 0;
   C97 : constant Integer := A97;
   S97 : String := "abc";
begin
   A97 := (9 - A97);
   B97 := (-B97);
   if A97 > C97 then
      S97 := "xyz";
   elsif A97 = 0 then
      B97 := 5;
   else
      S97 := "abc";
   end if;
   for I97 in 1 .. 3 loop
      for J97 in 0 .. I97 loop
         Silver_IO.Put (Integer'Image ((I97 * J97)));
      end loop;
      B97 := (I97 - 3);
   end loop;
   A97 := 7;
   Silver_IO.Put_Line (S97 & Integer'Image (B97));
end Main;
