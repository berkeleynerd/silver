procedure Iteration_Probe with SPARK_Mode is
   A : constant array (-1 .. 3) of Integer := (-1, 0, 1, 2, 3);
   B : array (1 .. 3) of Integer := (0, 0, 0);
   E : Integer := 0;
begin
   for E of A loop
      if E >= 1 and then E <= 3 then
         B (E) := (E + 1);
      end if;
   end loop;
   for F of reverse A loop
      for I in 1 .. 3 loop
         B (I) := F;
      end loop;
   end loop;
   for G of A loop
      if G >= 1 and then G <= 3 then
         for H of reverse A loop
            B (G) := H;
         end loop;
      end if;
   end loop;
   E := A (1);
end Iteration_Probe;
