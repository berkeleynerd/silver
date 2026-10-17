with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A79 : Integer range 0 .. 9 := 3;
   B79 : Integer range -5 .. 5 := 0;
   C79 : constant Integer := A79;
   S79 : String := "abc";
begin
   A79 := (9 - A79);
   B79 := (-B79);
   if A79 > C79 then
      S79 := "xyz";
   elsif A79 = 0 then
      B79 := 5;
   else
      S79 := "abc";
   end if;
   for I79 in 1 .. 3 loop
      for J79 in 0 .. I79 loop
         Silver_IO.Put (Integer'Image ((I79 * J79)));
      end loop;
      B79 := (I79 - 3);
   end loop;
   A79 := 7;
   Silver_IO.Put_Line (S79 & Integer'Image (B79));
end Main;
