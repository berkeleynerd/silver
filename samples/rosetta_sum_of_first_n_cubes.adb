with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- The sum of the first N cubes is the square of N*(N+1)/2.
   Triangular : Integer range 0 .. 1225 := 0;
begin
   for N in 0 .. 49 loop
      Triangular := ((N * (N + 1)) / 2);
      Silver_IO.Put_Line (Integer'Image ((Triangular * Triangular)));
   end loop;
end Main;
