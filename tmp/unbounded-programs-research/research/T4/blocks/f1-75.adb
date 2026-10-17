with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A75 : Integer range 0 .. 9 := 3;
   B75 : Integer range -5 .. 5 := 0;
   C75 : constant Integer := A75;
   S75 : String := "abc";
begin
   A75 := (9 - A75);
   B75 := (-B75);
   if A75 > C75 then
      S75 := "xyz";
   elsif A75 = 0 then
      B75 := 5;
   else
      S75 := "abc";
   end if;
   for I75 in 1 .. 3 loop
      for J75 in 0 .. I75 loop
         Silver_IO.Put (Integer'Image ((I75 * J75)));
      end loop;
      B75 := (I75 - 3);
   end loop;
   A75 := 7;
   Silver_IO.Put_Line (S75 & Integer'Image (B75));
end Main;
