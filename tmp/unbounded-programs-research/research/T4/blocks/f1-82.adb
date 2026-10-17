with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A82 : Integer range 0 .. 9 := 3;
   B82 : Integer range -5 .. 5 := 0;
   C82 : constant Integer := A82;
   S82 : String := "abc";
begin
   A82 := (9 - A82);
   B82 := (-B82);
   if A82 > C82 then
      S82 := "xyz";
   elsif A82 = 0 then
      B82 := 5;
   else
      S82 := "abc";
   end if;
   for I82 in 1 .. 3 loop
      for J82 in 0 .. I82 loop
         Silver_IO.Put (Integer'Image ((I82 * J82)));
      end loop;
      B82 := (I82 - 3);
   end loop;
   A82 := 7;
   Silver_IO.Put_Line (S82 & Integer'Image (B82));
end Main;
