with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A72 : Integer range 0 .. 9 := 3;
   B72 : Integer range -5 .. 5 := 0;
   C72 : constant Integer := A72;
   S72 : String := "abc";
begin
   A72 := (9 - A72);
   B72 := (-B72);
   if A72 > C72 then
      S72 := "xyz";
   elsif A72 = 0 then
      B72 := 5;
   else
      S72 := "abc";
   end if;
   for I72 in 1 .. 3 loop
      for J72 in 0 .. I72 loop
         Silver_IO.Put (Integer'Image ((I72 * J72)));
      end loop;
      B72 := (I72 - 3);
   end loop;
   A72 := 7;
   Silver_IO.Put_Line (S72 & Integer'Image (B72));
end Main;
