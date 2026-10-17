with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A42 : Integer range 0 .. 9 := 3;
   B42 : Integer range -5 .. 5 := 0;
   C42 : constant Integer := A42;
   S42 : String := "abc";
begin
   A42 := (9 - A42);
   B42 := (-B42);
   if A42 > C42 then
      S42 := "xyz";
   elsif A42 = 0 then
      B42 := 5;
   else
      S42 := "abc";
   end if;
   for I42 in 1 .. 3 loop
      for J42 in 0 .. I42 loop
         Silver_IO.Put (Integer'Image ((I42 * J42)));
      end loop;
      B42 := (I42 - 3);
   end loop;
   A42 := 7;
   Silver_IO.Put_Line (S42 & Integer'Image (B42));
end Main;
