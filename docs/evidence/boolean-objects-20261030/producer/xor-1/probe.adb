procedure Probe (A, B : Boolean; N : Integer; R : out Boolean) is
   pragma SPARK_Mode (On);
begin
   if N < Integer'Last then
      R := ((N + 1) > N) xor A;
   else
      R := A;
   end if;
end Probe;
