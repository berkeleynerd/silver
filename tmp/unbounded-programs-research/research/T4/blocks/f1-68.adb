with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A68 : Integer range 0 .. 9 := 3;
   B68 : Integer range -5 .. 5 := 0;
   C68 : constant Integer := A68;
   S68 : String := "abc";
begin
   A68 := (9 - A68);
   B68 := (-B68);
   if A68 > C68 then
      S68 := "xyz";
   elsif A68 = 0 then
      B68 := 5;
   else
      S68 := "abc";
   end if;
   for I68 in 1 .. 3 loop
      for J68 in 0 .. I68 loop
         Silver_IO.Put (Integer'Image ((I68 * J68)));
      end loop;
      B68 := (I68 - 3);
   end loop;
   A68 := 7;
   Silver_IO.Put_Line (S68 & Integer'Image (B68));
end Main;
