with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A8 : Integer range 0 .. 9 := 3;
   B8 : Integer range -5 .. 5 := 0;
   C8 : constant Integer := A8;
   S8 : String := "abc";
begin
   A8 := (9 - A8);
   B8 := (-B8);
   if A8 > C8 then
      S8 := "xyz";
   elsif A8 = 0 then
      B8 := 5;
   else
      S8 := "abc";
   end if;
   for I8 in 1 .. 3 loop
      for J8 in 0 .. I8 loop
         Silver_IO.Put (Integer'Image ((I8 * J8)));
      end loop;
      B8 := (I8 - 3);
   end loop;
   A8 := 7;
   Silver_IO.Put_Line (S8 & Integer'Image (B8));
end Main;
