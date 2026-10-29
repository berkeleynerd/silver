procedure Hiding_Probe with SPARK_Mode is
   A : constant array (1 .. 2) of Integer := (1, 2);
begin
   for A of A loop
      null;
   end loop;
end Hiding_Probe;
