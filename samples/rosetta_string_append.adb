with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Buffer : String := "Hello        ";
   Suffix : constant String := ", world!";
   Len : Integer range 0 .. 13 := 5;
   Start : Integer range 0 .. 5 := 0;
begin
   for Attempt in 1 .. 2 loop
      if Len <= 5 then
         Start := Len;
         Len := (Len + 8);
         for J in 1 .. 8 loop
            Buffer ((Start + J)) := Suffix (J);
         end loop;
      else
         Silver_IO.Put_Line ("full");
      end if;
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
end Main;
