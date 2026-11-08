with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Factorial_Argument is Integer range 0 .. 12;
   subtype Factorial_Value is Integer range 1 .. 479_001_600;

   function Factorial (N : in Factorial_Argument) return Factorial_Value is
      Result : Factorial_Value := 1;
   begin
      for Factor in 1 .. N loop
         if Result <= 39_916_800 then
            Result := (Result * Factor);
         end if;
      end loop;
      return Result;
   end Factorial;

   Value : Factorial_Value := 1;
begin
   for N in 0 .. 12 loop
      Value := Factorial (N);
      Silver_IO.Put_Line (Integer'Image (N) & "! =" & Integer'Image (Value));
   end loop;
end Main;
