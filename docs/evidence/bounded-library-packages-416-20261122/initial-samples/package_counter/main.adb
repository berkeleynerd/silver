with Counter, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Result : Counter.Count := 0;
begin
   Counter.Reset;
   for I in 1 .. 12 loop
      Counter.Increment;
   end loop;
   Result := Counter.Read;
   Silver_IO.Put_Line (Integer'Image (Result));
end Main;
