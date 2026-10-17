with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A83 : Integer range 0 .. 9 := 3;
   B83 : Integer range -5 .. 5 := 0;
   C83 : constant Integer := A83;
   S83 : String := "abc";
begin
   A83 := (9 - A83);
   B83 := (-B83);
   if A83 > C83 then
      S83 := "xyz";
   elsif A83 = 0 then
      B83 := 5;
   else
      S83 := "abc";
   end if;
   for I83 in 1 .. 3 loop
      for J83 in 0 .. I83 loop
         Silver_IO.Put (Integer'Image ((I83 * J83)));
      end loop;
      B83 := (I83 - 3);
   end loop;
   A83 := 7;
   Silver_IO.Put_Line (S83 & Integer'Image (B83));
end Main;
