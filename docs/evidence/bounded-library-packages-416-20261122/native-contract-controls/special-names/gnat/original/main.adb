with GNAT, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Result : GNAT.Count := 0;
begin
   GNAT.Reset;
   for I in 1 .. 12 loop
      GNAT.Increment;
   end loop;
   Result := GNAT.Read;
   Silver_IO.Put_Line (Integer'Image (Result));
end Main;
