with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A0 : Integer range 0 .. 9 := 3;
   B0 : Integer range -5 .. 5 := 0;
   C0 : constant Integer := A0;
   S0 : String := "abc";
begin
   A0 := (9 - A0);
   B0 := (-B0);
   if A0 > C0 then
      S0 := "xyz";
   elsif A0 = 0 then
      B0 := 5;
   else
      S0 := "abc";
   end if;
   for I0 in 1 .. 3 loop
      for J0 in 0 .. I0 loop
         Silver_IO.Put (Integer'Image ((I0 * J0)));
      end loop;
      B0 := (I0 - 3);
   end loop;
   A0 := 7;
   Silver_IO.Put_Line (S0 & Integer'Image (B0));
end Main;
