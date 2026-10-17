with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A47 : Integer range 0 .. 9 := 3;
   B47 : Integer range -5 .. 5 := 0;
   C47 : constant Integer := A47;
   S47 : String := "abc";
begin
   A47 := (9 - A47);
   B47 := (-B47);
   if A47 > C47 then
      S47 := "xyz";
   elsif A47 = 0 then
      B47 := 5;
   else
      S47 := "abc";
   end if;
   for I47 in 1 .. 3 loop
      for J47 in 0 .. I47 loop
         Silver_IO.Put (Integer'Image ((I47 * J47)));
      end loop;
      B47 := (I47 - 3);
   end loop;
   A47 := 7;
   Silver_IO.Put_Line (S47 & Integer'Image (B47));
end Main;
