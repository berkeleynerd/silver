with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A49 : Integer range 0 .. 9 := 3;
   B49 : Integer range -5 .. 5 := 0;
   C49 : constant Integer := A49;
   S49 : String := "abc";
begin
   A49 := (9 - A49);
   B49 := (-B49);
   if A49 > C49 then
      S49 := "xyz";
   elsif A49 = 0 then
      B49 := 5;
   else
      S49 := "abc";
   end if;
   for I49 in 1 .. 3 loop
      for J49 in 0 .. I49 loop
         Silver_IO.Put (Integer'Image ((I49 * J49)));
      end loop;
      B49 := (I49 - 3);
   end loop;
   A49 := 7;
   Silver_IO.Put_Line (S49 & Integer'Image (B49));
end Main;
