with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Largest : Integer range 1 .. 50 := 1;
begin
   for N in 1 .. 100 loop
      -- a(1)=1; ascending divisors leave the largest proper divisor last.
      Largest := 1;
      for D in 1 .. (N / 2) loop
         if (N mod D) = 0 then
            Largest := D;
         end if;
      end loop;
      if Largest < 10 then
         Silver_IO.Put (" ");
      end if;
      Silver_IO.Put (Integer'Image (Largest));
      if (N mod 10) = 0 then
         Silver_IO.Put_Line ("");
      end if;
   end loop;
end Main;
