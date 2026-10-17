with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A60 : Integer range 0 .. 9 := 3;
   B60 : Integer range -5 .. 5 := 0;
   C60 : constant Integer := A60;
   S60 : String := "abc";
begin
   A60 := (9 - A60);
   B60 := (-B60);
   if A60 > C60 then
      S60 := "xyz";
   elsif A60 = 0 then
      B60 := 5;
   else
      S60 := "abc";
   end if;
   for I60 in 1 .. 3 loop
      for J60 in 0 .. I60 loop
         Silver_IO.Put (Integer'Image ((I60 * J60)));
      end loop;
      B60 := (I60 - 3);
   end loop;
   A60 := 7;
   Silver_IO.Put_Line (S60 & Integer'Image (B60));
end Main;
