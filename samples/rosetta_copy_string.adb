with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Source : String := "Hello";
   Copied : String := Source;
begin
   Silver_IO.Put_Line ("Before: " & Source & " / " & Copied);
   Source := "World";
   Silver_IO.Put_Line ("After: " & Source & " / " & Copied);
end Main;
