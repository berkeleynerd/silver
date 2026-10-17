with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A21 : Integer range 0 .. 9 := 3;
   B21 : Integer range -5 .. 5 := 0;
   C21 : constant Integer := A21;
   S21 : String := "abc";
begin
   A21 := (9 - A21);
   B21 := (-B21);
   if A21 > C21 then
      S21 := "xyz";
   elsif A21 = 0 then
      B21 := 5;
   else
      S21 := "abc";
   end if;
   for I21 in 1 .. 3 loop
      for J21 in 0 .. I21 loop
         Silver_IO.Put (Integer'Image ((I21 * J21)));
      end loop;
      B21 := (I21 - 3);
   end loop;
   A21 := 7;
   Silver_IO.Put_Line (S21 & Integer'Image (B21));
end Main;
