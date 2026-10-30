procedure Probe (A, B : Boolean; N : Integer; R : out Boolean) is
   pragma SPARK_Mode (On);
begin
   if N < Integer'Last then
      R := ((((((((((N + 1) > N) /= A) /= B) /= A) /= B) /= A) /= B) /= A) /= B);
   else
      R := A;
   end if;
end Probe;
