with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Positive_Input is Integer range 1 .. 100;
   Values : constant array (1 .. 9) of Positive_Input :=
     (1, 2, 6, 12, 13, 28, 36, 97, 100);
begin
   for Number of Values loop
      Silver_IO.Put (Integer'Image (Number) & ":");
      -- Every positive divisor is at most Number; no candidate is skipped.
      for Divisor in 1 .. Number loop
         if (Number mod Divisor) = 0 then
            Silver_IO.Put (Integer'Image (Divisor));
         end if;
      end loop;
      Silver_IO.Put_Line ("");
   end loop;
end Main;
