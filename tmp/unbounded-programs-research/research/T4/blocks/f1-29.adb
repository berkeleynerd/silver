with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A29 : Integer range 0 .. 9 := 3;
   B29 : Integer range -5 .. 5 := 0;
   C29 : constant Integer := A29;
   S29 : String := "abc";
begin
   A29 := (9 - A29);
   B29 := (-B29);
   if A29 > C29 then
      S29 := "xyz";
   elsif A29 = 0 then
      B29 := 5;
   else
      S29 := "abc";
   end if;
   for I29 in 1 .. 3 loop
      for J29 in 0 .. I29 loop
         Silver_IO.Put (Integer'Image ((I29 * J29)));
      end loop;
      B29 := (I29 - 3);
   end loop;
   A29 := 7;
   Silver_IO.Put_Line (S29 & Integer'Image (B29));
end Main;
