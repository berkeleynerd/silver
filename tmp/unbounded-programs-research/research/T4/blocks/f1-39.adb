with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A39 : Integer range 0 .. 9 := 3;
   B39 : Integer range -5 .. 5 := 0;
   C39 : constant Integer := A39;
   S39 : String := "abc";
begin
   A39 := (9 - A39);
   B39 := (-B39);
   if A39 > C39 then
      S39 := "xyz";
   elsif A39 = 0 then
      B39 := 5;
   else
      S39 := "abc";
   end if;
   for I39 in 1 .. 3 loop
      for J39 in 0 .. I39 loop
         Silver_IO.Put (Integer'Image ((I39 * J39)));
      end loop;
      B39 := (I39 - 3);
   end loop;
   A39 := 7;
   Silver_IO.Put_Line (S39 & Integer'Image (B39));
end Main;
