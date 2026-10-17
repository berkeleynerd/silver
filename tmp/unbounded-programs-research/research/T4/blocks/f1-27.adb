with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A27 : Integer range 0 .. 9 := 3;
   B27 : Integer range -5 .. 5 := 0;
   C27 : constant Integer := A27;
   S27 : String := "abc";
begin
   A27 := (9 - A27);
   B27 := (-B27);
   if A27 > C27 then
      S27 := "xyz";
   elsif A27 = 0 then
      B27 := 5;
   else
      S27 := "abc";
   end if;
   for I27 in 1 .. 3 loop
      for J27 in 0 .. I27 loop
         Silver_IO.Put (Integer'Image ((I27 * J27)));
      end loop;
      B27 := (I27 - 3);
   end loop;
   A27 := 7;
   Silver_IO.Put_Line (S27 & Integer'Image (B27));
end Main;
