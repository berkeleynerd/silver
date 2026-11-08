with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Positive_Input is Integer range 1 .. 100;
   subtype Divisor_Count is Integer range 0 .. 100;

   function Tau (N : in Positive_Input) return Divisor_Count is
      Count : Divisor_Count := 0;
   begin
      for Divisor in 1 .. N loop
         if (N mod Divisor) = 0 then
            -- At most 99 candidates precede any iteration in this domain.
            if Count < 100 then
               Count := (Count + 1);
            end if;
         end if;
      end loop;
      return Count;
   end Tau;

   Value : Divisor_Count := 0;
begin
   for N in 1 .. 100 loop
      Value := Tau (N);
      Silver_IO.Put_Line (Integer'Image (N) & ":" & Integer'Image (Value));
   end loop;
end Main;
