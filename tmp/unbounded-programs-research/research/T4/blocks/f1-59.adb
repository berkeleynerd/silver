with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A59 : Integer range 0 .. 9 := 3;
   B59 : Integer range -5 .. 5 := 0;
   C59 : constant Integer := A59;
   S59 : String := "abc";
begin
   A59 := (9 - A59);
   B59 := (-B59);
   if A59 > C59 then
      S59 := "xyz";
   elsif A59 = 0 then
      B59 := 5;
   else
      S59 := "abc";
   end if;
   for I59 in 1 .. 3 loop
      for J59 in 0 .. I59 loop
         Silver_IO.Put (Integer'Image ((I59 * J59)));
      end loop;
      B59 := (I59 - 3);
   end loop;
   A59 := 7;
   Silver_IO.Put_Line (S59 & Integer'Image (B59));
end Main;
