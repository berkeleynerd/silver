with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Positive_Input is Integer range 1 .. 100;
   subtype Divisor_Sum_Value is Integer range 0 .. 5050;

   function Sum_Of_Divisors (N : in Positive_Input) return Divisor_Sum_Value is
      Result : Divisor_Sum_Value := 0;
   begin
      for Divisor in 1 .. N loop
         if (N mod Divisor) = 0 then
            -- Earlier candidates sum to at most 1 + ... + 99 = 4950.
            if Result <= 4950 then
               Result := (Result + Divisor);
            end if;
         end if;
      end loop;
      return Result;
   end Sum_Of_Divisors;

   Value : Divisor_Sum_Value := 0;
begin
   for N in 1 .. 100 loop
      Value := Sum_Of_Divisors (N);
      Silver_IO.Put_Line (Integer'Image (N) & ":" & Integer'Image (Value));
   end loop;
end Main;
