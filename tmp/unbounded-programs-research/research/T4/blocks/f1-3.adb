with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A3 : Integer range 0 .. 9 := 3;
   B3 : Integer range -5 .. 5 := 0;
   C3 : constant Integer := A3;
   S3 : String := "abc";
begin
   A3 := (9 - A3);
   B3 := (-B3);
   if A3 > C3 then
      S3 := "xyz";
   elsif A3 = 0 then
      B3 := 5;
   else
      S3 := "abc";
   end if;
   for I3 in 1 .. 3 loop
      for J3 in 0 .. I3 loop
         Silver_IO.Put (Integer'Image ((I3 * J3)));
      end loop;
      B3 := (I3 - 3);
   end loop;
   A3 := 7;
   Silver_IO.Put_Line (S3 & Integer'Image (B3));
end Main;
