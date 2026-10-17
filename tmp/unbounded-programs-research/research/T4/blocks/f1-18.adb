with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A18 : Integer range 0 .. 9 := 3;
   B18 : Integer range -5 .. 5 := 0;
   C18 : constant Integer := A18;
   S18 : String := "abc";
begin
   A18 := (9 - A18);
   B18 := (-B18);
   if A18 > C18 then
      S18 := "xyz";
   elsif A18 = 0 then
      B18 := 5;
   else
      S18 := "abc";
   end if;
   for I18 in 1 .. 3 loop
      for J18 in 0 .. I18 loop
         Silver_IO.Put (Integer'Image ((I18 * J18)));
      end loop;
      B18 := (I18 - 3);
   end loop;
   A18 := 7;
   Silver_IO.Put_Line (S18 & Integer'Image (B18));
end Main;
