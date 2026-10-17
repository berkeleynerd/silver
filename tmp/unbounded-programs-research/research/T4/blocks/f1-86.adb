with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A86 : Integer range 0 .. 9 := 3;
   B86 : Integer range -5 .. 5 := 0;
   C86 : constant Integer := A86;
   S86 : String := "abc";
begin
   A86 := (9 - A86);
   B86 := (-B86);
   if A86 > C86 then
      S86 := "xyz";
   elsif A86 = 0 then
      B86 := 5;
   else
      S86 := "abc";
   end if;
   for I86 in 1 .. 3 loop
      for J86 in 0 .. I86 loop
         Silver_IO.Put (Integer'Image ((I86 * J86)));
      end loop;
      B86 := (I86 - 3);
   end loop;
   A86 := 7;
   Silver_IO.Put_Line (S86 & Integer'Image (B86));
end Main;
