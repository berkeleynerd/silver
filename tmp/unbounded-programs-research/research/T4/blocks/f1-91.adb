with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A91 : Integer range 0 .. 9 := 3;
   B91 : Integer range -5 .. 5 := 0;
   C91 : constant Integer := A91;
   S91 : String := "abc";
begin
   A91 := (9 - A91);
   B91 := (-B91);
   if A91 > C91 then
      S91 := "xyz";
   elsif A91 = 0 then
      B91 := 5;
   else
      S91 := "abc";
   end if;
   for I91 in 1 .. 3 loop
      for J91 in 0 .. I91 loop
         Silver_IO.Put (Integer'Image ((I91 * J91)));
      end loop;
      B91 := (I91 - 3);
   end loop;
   A91 := 7;
   Silver_IO.Put_Line (S91 & Integer'Image (B91));
end Main;
