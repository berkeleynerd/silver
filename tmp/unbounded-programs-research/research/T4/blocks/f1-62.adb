with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A62 : Integer range 0 .. 9 := 3;
   B62 : Integer range -5 .. 5 := 0;
   C62 : constant Integer := A62;
   S62 : String := "abc";
begin
   A62 := (9 - A62);
   B62 := (-B62);
   if A62 > C62 then
      S62 := "xyz";
   elsif A62 = 0 then
      B62 := 5;
   else
      S62 := "abc";
   end if;
   for I62 in 1 .. 3 loop
      for J62 in 0 .. I62 loop
         Silver_IO.Put (Integer'Image ((I62 * J62)));
      end loop;
      B62 := (I62 - 3);
   end loop;
   A62 := 7;
   Silver_IO.Put_Line (S62 & Integer'Image (B62));
end Main;
