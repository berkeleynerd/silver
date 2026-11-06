with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Source : constant String := "abcd";
   Middle : String := Source (2 .. 3);
   Empty : constant String := Source (0 .. (-1));
   Original : constant Character := Middle (2);
   Saved : Character := Original;
begin
   Middle (2) := 'X';
   Saved := Middle (3);
   if Original = 'b' and then Saved = 'c' then
      Silver_IO.Put_Line (Middle & Empty);
   end if;
   Middle := Source (1 .. 2);
   Silver_IO.Put_Line (Middle (2 .. 3));
end Main;
