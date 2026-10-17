with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A70 : Integer range 0 .. 9 := 3;
   B70 : Integer range -5 .. 5 := 0;
   C70 : constant Integer := A70;
   S70 : String := "abc";
begin
   A70 := (9 - A70);
   B70 := (-B70);
   if A70 > C70 then
      S70 := "xyz";
   elsif A70 = 0 then
      B70 := 5;
   else
      S70 := "abc";
   end if;
   for I70 in 1 .. 3 loop
      for J70 in 0 .. I70 loop
         Silver_IO.Put (Integer'Image ((I70 * J70)));
      end loop;
      B70 := (I70 - 3);
   end loop;
   A70 := 7;
   Silver_IO.Put_Line (S70 & Integer'Image (B70));
end Main;
