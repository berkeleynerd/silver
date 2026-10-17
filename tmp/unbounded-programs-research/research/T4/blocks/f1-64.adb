with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A64 : Integer range 0 .. 9 := 3;
   B64 : Integer range -5 .. 5 := 0;
   C64 : constant Integer := A64;
   S64 : String := "abc";
begin
   A64 := (9 - A64);
   B64 := (-B64);
   if A64 > C64 then
      S64 := "xyz";
   elsif A64 = 0 then
      B64 := 5;
   else
      S64 := "abc";
   end if;
   for I64 in 1 .. 3 loop
      for J64 in 0 .. I64 loop
         Silver_IO.Put (Integer'Image ((I64 * J64)));
      end loop;
      B64 := (I64 - 3);
   end loop;
   A64 := 7;
   Silver_IO.Put_Line (S64 & Integer'Image (B64));
end Main;
