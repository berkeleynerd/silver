with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   First : constant String := "racecar";
   Second : constant String := "silver";
   Palindrome : Boolean := True;
begin
   for Index in 1 .. 3 loop
      if First (Index) /= First ((8 - Index)) then
         Palindrome := False;
      end if;
   end loop;
   if Palindrome then
      Silver_IO.Put_Line (First & ": palindrome");
   else
      Silver_IO.Put_Line (First & ": not a palindrome");
   end if;
   Palindrome := True;
   for Index in 1 .. 3 loop
      if Second (Index) /= Second ((7 - Index)) then
         Palindrome := False;
      end if;
   end loop;
   if Palindrome then
      Silver_IO.Put_Line (Second & ": palindrome");
   else
      Silver_IO.Put_Line (Second & ": not a palindrome");
   end if;
end Main;
