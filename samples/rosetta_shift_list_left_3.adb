with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Source : constant array (1 .. 9) of Integer := (1, 2, 3, 4, 5, 6, 7, 8, 9);
   Result : array (1 .. 9) of Integer := (0, 0, 0, 0, 0, 0, 0, 0, 0);
begin
   for I in 1 .. 9 loop
      Silver_IO.Put (Integer'Image (Source (I)));
   end loop;
   Silver_IO.Put_Line ("");
   for I in 1 .. 6 loop
      Result (I) := Source ((I + 3));
   end loop;
   for I in 7 .. 9 loop
      Result (I) := Source ((I - 6));
   end loop;
   for I in 1 .. 9 loop
      Silver_IO.Put (Integer'Image (Result (I)));
   end loop;
   Silver_IO.Put_Line ("");
end Main;
