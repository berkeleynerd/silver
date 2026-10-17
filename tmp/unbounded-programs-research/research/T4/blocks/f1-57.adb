with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A57 : Integer range 0 .. 9 := 3;
   B57 : Integer range -5 .. 5 := 0;
   C57 : constant Integer := A57;
   S57 : String := "abc";
begin
   A57 := (9 - A57);
   B57 := (-B57);
   if A57 > C57 then
      S57 := "xyz";
   elsif A57 = 0 then
      B57 := 5;
   else
      S57 := "abc";
   end if;
   for I57 in 1 .. 3 loop
      for J57 in 0 .. I57 loop
         Silver_IO.Put (Integer'Image ((I57 * J57)));
      end loop;
      B57 := (I57 - 3);
   end loop;
   A57 := 7;
   Silver_IO.Put_Line (S57 & Integer'Image (B57));
end Main;
