with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Buffer : String := "World!      ";
   Prefix : constant String := "Hello ";
   Len : Integer range 0 .. 12 := 6;
begin
   for Attempt in 1 .. 2 loop
      if Len <= 6 then
         Len := (Len + 6);
         for J in reverse 1 .. (Len - 6) loop
            Buffer ((J + 6)) := Buffer (J);
         end loop;
         for J in 1 .. 6 loop
            Buffer (J) := Prefix (J);
         end loop;
      else
         Silver_IO.Put_Line ("full");
      end if;
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
end Main;
