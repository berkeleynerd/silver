with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A89 : Integer range 0 .. 9 := 3;
   B89 : Integer range -5 .. 5 := 0;
   C89 : constant Integer := A89;
   S89 : String := "abc";
begin
   A89 := (9 - A89);
   B89 := (-B89);
   if A89 > C89 then
      S89 := "xyz";
   elsif A89 = 0 then
      B89 := 5;
   else
      S89 := "abc";
   end if;
   for I89 in 1 .. 3 loop
      for J89 in 0 .. I89 loop
         Silver_IO.Put (Integer'Image ((I89 * J89)));
      end loop;
      B89 := (I89 - 3);
   end loop;
   A89 := 7;
   Silver_IO.Put_Line (S89 & Integer'Image (B89));
end Main;
