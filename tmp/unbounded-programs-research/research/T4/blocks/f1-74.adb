with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A74 : Integer range 0 .. 9 := 3;
   B74 : Integer range -5 .. 5 := 0;
   C74 : constant Integer := A74;
   S74 : String := "abc";
begin
   A74 := (9 - A74);
   B74 := (-B74);
   if A74 > C74 then
      S74 := "xyz";
   elsif A74 = 0 then
      B74 := 5;
   else
      S74 := "abc";
   end if;
   for I74 in 1 .. 3 loop
      for J74 in 0 .. I74 loop
         Silver_IO.Put (Integer'Image ((I74 * J74)));
      end loop;
      B74 := (I74 - 3);
   end loop;
   A74 := 7;
   Silver_IO.Put_Line (S74 & Integer'Image (B74));
end Main;
