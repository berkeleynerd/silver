with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A32 : Integer range 0 .. 9 := 3;
   B32 : Integer range -5 .. 5 := 0;
   C32 : constant Integer := A32;
   S32 : String := "abc";
begin
   A32 := (9 - A32);
   B32 := (-B32);
   if A32 > C32 then
      S32 := "xyz";
   elsif A32 = 0 then
      B32 := 5;
   else
      S32 := "abc";
   end if;
   for I32 in 1 .. 3 loop
      for J32 in 0 .. I32 loop
         Silver_IO.Put (Integer'Image ((I32 * J32)));
      end loop;
      B32 := (I32 - 3);
   end loop;
   A32 := 7;
   Silver_IO.Put_Line (S32 & Integer'Image (B32));
end Main;
