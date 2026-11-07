with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Input_Value is Integer range -1000 .. 1000;
   First : constant array (1 .. 8) of Input_Value :=
      (48, 0, 42, 0, -48, 144, 610, 1000);
   Second : constant array (1 .. 8) of Input_Value :=
      (18, 42, 0, 0, 18, -233, 987, 999);
   A : Input_Value := 0;
   B : Input_Value := 0;
   Remainder : Integer range 0 .. 999 := 0;
begin
   -- Use the conventional extension gcd (0, 0) = 0.
   for Pair in 1 .. 8 loop
      A := First (Pair);
      B := Second (Pair);
      if A < 0 then
         A := (-A);
      end if;
      if B < 0 then
         B := (-B);
      end if;
      -- Two Euclidean steps at least halve B; 2**10 exceeds 1000.
      for Step in 1 .. 20 loop
         if B > 0 then
            Remainder := (A mod B);
            A := B;
            B := Remainder;
         end if;
      end loop;
      Silver_IO.Put_Line
         ("gcd(" & Integer'Image (First (Pair)) & "," &
          Integer'Image (Second (Pair)) & ") =" & Integer'Image (A));
   end loop;
end Main;
