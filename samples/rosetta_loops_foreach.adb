with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Values : constant array (1 .. 5) of Integer := (-1, 0, 1, 2, 3);
begin
   for Value of Values loop
      Silver_IO.Put_Line (Integer'Image (Value));
   end loop;
end Main;
