with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A1 : Integer range 0 .. 9 := 3;
   B1 : Integer range -5 .. 5 := 0;
   C1 : constant Integer := A1;
   S1 : String := "abc";
begin
   A1 := (9 - A1);
   B1 := (-B1);
   if A1 > C1 then
      S1 := "xyz";
   elsif A1 = 0 then
      B1 := 5;
   else
      S1 := "abc";
   end if;
   for I1 in 1 .. 3 loop
      for J1 in 0 .. I1 loop
         Silver_IO.Put (Integer'Image ((I1 * J1)));
      end loop;
      B1 := (I1 - 3);
   end loop;
   A1 := 7;
   Silver_IO.Put_Line (S1 & Integer'Image (B1));
end Main;
