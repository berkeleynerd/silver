with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- Keep the minimum of the four distances I-1, 10-I, J-1 and 10-J.
   -- Every candidate independently lies in 0 .. 9.
   M : Integer range 0 .. 9 := 0;
begin
   for I in 1 .. 10 loop
      for J in 1 .. 10 loop
         M := (I - 1);
         if (10 - I) < M then
            M := (10 - I);
         end if;
         if (J - 1) < M then
            M := (J - 1);
         end if;
         if (10 - J) < M then
            M := (10 - J);
         end if;
         Silver_IO.Put (Integer'Image (M));
      end loop;
      Silver_IO.Put_Line ("");
   end loop;
end Main;
