with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A87 : Integer range 0 .. 9 := 3;
   B87 : Integer range -5 .. 5 := 0;
   C87 : constant Integer := A87;
   S87 : String := "abc";
begin
   A87 := (9 - A87);
   B87 := (-B87);
   if A87 > C87 then
      S87 := "xyz";
   elsif A87 = 0 then
      B87 := 5;
   else
      S87 := "abc";
   end if;
   for I87 in 1 .. 3 loop
      for J87 in 0 .. I87 loop
         Silver_IO.Put (Integer'Image ((I87 * J87)));
      end loop;
      B87 := (I87 - 3);
   end loop;
   A87 := 7;
   Silver_IO.Put_Line (S87 & Integer'Image (B87));
end Main;
