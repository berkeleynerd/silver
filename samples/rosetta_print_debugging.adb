with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Value : Integer range 0 .. 9 := 2;
begin
   Silver_IO.Put_Line ("TRACE rosetta_print_debugging.adb:8:4 Value := (9 - Value);");
   Silver_IO.Put_Line ("before:" & Integer'Image (Value));
   Value := (9 - Value);
   Silver_IO.Put_Line ("after:" & Integer'Image (Value));
end Main;
