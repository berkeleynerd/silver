with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Step : constant Integer := 2;
begin
   for I in 1 .. 5 loop
      Silver_IO.Put_Line (Integer'Image ((I * Step)));
   end loop;
end Main;
