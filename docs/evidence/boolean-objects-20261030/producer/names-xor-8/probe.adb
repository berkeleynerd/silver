procedure Probe (A, B : Boolean; N : Integer; R : out Integer) is
   pragma SPARK_Mode (On);
begin
   if A xor B xor A xor B xor A xor B xor A xor B xor A then
      if N < Integer'Last then
         R := N + 1;
      else
         R := N;
      end if;
   else
      R := N;
   end if;
end Probe;
