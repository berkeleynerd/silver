with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A88 : Integer range 0 .. 9 := 3;
   B88 : Integer range -5 .. 5 := 0;
   C88 : constant Integer := A88;
   S88 : String := "abc";
begin
   A88 := (9 - A88);
   B88 := (-B88);
   if A88 > C88 then
      S88 := "xyz";
   elsif A88 = 0 then
      B88 := 5;
   else
      S88 := "abc";
   end if;
   for I88 in 1 .. 3 loop
      for J88 in 0 .. I88 loop
         Silver_IO.Put (Integer'Image ((I88 * J88)));
      end loop;
      B88 := (I88 - 3);
   end loop;
   A88 := 7;
   Silver_IO.Put_Line (S88 & Integer'Image (B88));
end Main;
