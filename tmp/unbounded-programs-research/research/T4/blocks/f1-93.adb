with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A93 : Integer range 0 .. 9 := 3;
   B93 : Integer range -5 .. 5 := 0;
   C93 : constant Integer := A93;
   S93 : String := "abc";
begin
   A93 := (9 - A93);
   B93 := (-B93);
   if A93 > C93 then
      S93 := "xyz";
   elsif A93 = 0 then
      B93 := 5;
   else
      S93 := "abc";
   end if;
   for I93 in 1 .. 3 loop
      for J93 in 0 .. I93 loop
         Silver_IO.Put (Integer'Image ((I93 * J93)));
      end loop;
      B93 := (I93 - 3);
   end loop;
   A93 := 7;
   Silver_IO.Put_Line (S93 & Integer'Image (B93));
end Main;
