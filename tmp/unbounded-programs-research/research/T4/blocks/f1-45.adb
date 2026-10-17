with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A45 : Integer range 0 .. 9 := 3;
   B45 : Integer range -5 .. 5 := 0;
   C45 : constant Integer := A45;
   S45 : String := "abc";
begin
   A45 := (9 - A45);
   B45 := (-B45);
   if A45 > C45 then
      S45 := "xyz";
   elsif A45 = 0 then
      B45 := 5;
   else
      S45 := "abc";
   end if;
   for I45 in 1 .. 3 loop
      for J45 in 0 .. I45 loop
         Silver_IO.Put (Integer'Image ((I45 * J45)));
      end loop;
      B45 := (I45 - 3);
   end loop;
   A45 := 7;
   Silver_IO.Put_Line (S45 & Integer'Image (B45));
end Main;
