with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A63 : Integer range 0 .. 9 := 3;
   B63 : Integer range -5 .. 5 := 0;
   C63 : constant Integer := A63;
   S63 : String := "abc";
begin
   A63 := (9 - A63);
   B63 := (-B63);
   if A63 > C63 then
      S63 := "xyz";
   elsif A63 = 0 then
      B63 := 5;
   else
      S63 := "abc";
   end if;
   for I63 in 1 .. 3 loop
      for J63 in 0 .. I63 loop
         Silver_IO.Put (Integer'Image ((I63 * J63)));
      end loop;
      B63 := (I63 - 3);
   end loop;
   A63 := 7;
   Silver_IO.Put_Line (S63 & Integer'Image (B63));
end Main;
