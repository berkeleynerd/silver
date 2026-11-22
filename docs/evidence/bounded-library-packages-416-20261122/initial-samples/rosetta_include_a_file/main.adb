with Included, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Result : Integer := 0;
begin
   Result := Included.Twice (4);
   Silver_IO.Put_Line (Integer'Image (Result));
end Main;
