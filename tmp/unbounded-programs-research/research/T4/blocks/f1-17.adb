with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A17 : Integer range 0 .. 9 := 3;
   B17 : Integer range -5 .. 5 := 0;
   C17 : constant Integer := A17;
   S17 : String := "abc";
begin
   A17 := (9 - A17);
   B17 := (-B17);
   if A17 > C17 then
      S17 := "xyz";
   elsif A17 = 0 then
      B17 := 5;
   else
      S17 := "abc";
   end if;
   for I17 in 1 .. 3 loop
      for J17 in 0 .. I17 loop
         Silver_IO.Put (Integer'Image ((I17 * J17)));
      end loop;
      B17 := (I17 - 3);
   end loop;
   A17 := 7;
   Silver_IO.Put_Line (S17 & Integer'Image (B17));
end Main;
