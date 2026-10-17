with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A44 : Integer range 0 .. 9 := 3;
   B44 : Integer range -5 .. 5 := 0;
   C44 : constant Integer := A44;
   S44 : String := "abc";
begin
   A44 := (9 - A44);
   B44 := (-B44);
   if A44 > C44 then
      S44 := "xyz";
   elsif A44 = 0 then
      B44 := 5;
   else
      S44 := "abc";
   end if;
   for I44 in 1 .. 3 loop
      for J44 in 0 .. I44 loop
         Silver_IO.Put (Integer'Image ((I44 * J44)));
      end loop;
      B44 := (I44 - 3);
   end loop;
   A44 := 7;
   Silver_IO.Put_Line (S44 & Integer'Image (B44));
end Main;
