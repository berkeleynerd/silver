with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Input_Value is Integer range -1000 .. 1000;
   subtype GCD_Value is Integer range 0 .. 1000;
   subtype LCM_Value is Integer range 0 .. 1_000_000;

   function GCD (Left : in Input_Value; Right : in Input_Value)
      return GCD_Value is
      A : GCD_Value := 0;
      B : GCD_Value := 0;
      Remainder : Integer range 0 .. 999 := 0;
   begin
      if Left < 0 then
         A := (-Left);
      else
         A := Left;
      end if;
      if Right < 0 then
         B := (-Right);
      else
         B := Right;
      end if;
      -- Two Euclidean steps at least halve B; 2**10 exceeds 1000.
      for Step in 1 .. 20 loop
         if B > 0 then
            Remainder := (A mod B);
            A := B;
            B := Remainder;
         end if;
      end loop;
      return A;
   end GCD;

   function LCM (Left : in Input_Value; Right : in Input_Value)
      return LCM_Value is
      Product : Integer range -1_000_000 .. 1_000_000 := 0;
      Divisor : GCD_Value := 0;
      Result : LCM_Value := 0;
   begin
      Product := (Left * Right);
      if Product < 0 then
         Product := (-Product);
      end if;
      Divisor := GCD (Left, Right);
      if Divisor > 0 then
         Result := (Product / Divisor);
      end if;
      return Result;
   end LCM;

   First : constant array (1 .. 12) of Input_Value :=
      (12, -12, 12, -12, 0, 12, 0, -1000, 1000, -1000, 1, 1000);
   Second : constant array (1 .. 12) of Input_Value :=
      (18, 18, -18, -18, 18, 0, 0, 1000, 999, -999, 1000, 1);
   Value : LCM_Value := 0;
begin
   for Pair in 1 .. 12 loop
      Value := LCM (First (Pair), Second (Pair));
      Silver_IO.Put_Line
         ("lcm(" & Integer'Image (First (Pair)) & "," &
          Integer'Image (Second (Pair)) & ") =" & Integer'Image (Value));
   end loop;
end Main;
