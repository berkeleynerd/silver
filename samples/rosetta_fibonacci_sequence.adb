with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Fibonacci_Index is Integer range 0 .. 46;
   subtype Fibonacci_Value is Integer range 0 .. 1_836_311_903;

   function Fibonacci (N : in Fibonacci_Index) return Fibonacci_Value is
      Previous : Fibonacci_Value := 0;
      Current : Fibonacci_Value := 1;
      Next_Value : Fibonacci_Value := 0;
   begin
      if N = 0 then
         Current := 0;
      else
         for Index in 2 .. N loop
            if Previous <= 701_408_733 and then Current <= 1_134_903_170 then
               Next_Value := (Previous + Current);
               Previous := Current;
               Current := Next_Value;
            end if;
         end loop;
      end if;
      return Current;
   end Fibonacci;

   Value : Fibonacci_Value := 0;
begin
   for N in 0 .. 46 loop
      Value := Fibonacci (N);
      Silver_IO.Put_Line ("Fibonacci" & Integer'Image (N) & " =" & Integer'Image (Value));
   end loop;
end Main;
