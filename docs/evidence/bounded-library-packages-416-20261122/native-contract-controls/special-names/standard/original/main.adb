with Standard, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Result : Standard.Count := 0;
begin
   Standard.Reset;
   for I in 1 .. 12 loop
      Standard.Increment;
   end loop;
   Result := Standard.Read;
   Silver_IO.Put_Line (Integer'Image (Result));
end Main;
