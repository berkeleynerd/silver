with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Text : String := "silver";
   Original : constant String := Text;
   Temporary : Character := ' ';
begin
   for Index in 1 .. 3 loop
      Temporary := Text (Index);
      Text (Index) := Text ((7 - Index));
      Text ((7 - Index)) := Temporary;
   end loop;
   Silver_IO.Put_Line (Original & " -> " & Text);
end Main;
