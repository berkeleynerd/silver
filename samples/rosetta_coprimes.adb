with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Input_Value is Integer range -1000 .. 1000;
   subtype GCD_Value is Integer range 0 .. 1000;

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

   function Coprime (Left : in Input_Value; Right : in Input_Value)
      return Boolean is
      Divisor : GCD_Value := 0;
   begin
      Divisor := GCD (Left, Right);
      return Divisor = 1;
   end Coprime;

   First : constant array (1 .. 13) of Input_Value :=
      (21, 17, 36, 18, 60, 0, 0, 1, -1, -1000, 1000, -1000, 1000);
   Second : constant array (1 .. 13) of Input_Value :=
      (15, 23, 12, 29, 15, 0, 1, 0, 1, 999, 1000, -999, 0);
   Value : Boolean := False;
begin
   for Pair in 1 .. 13 loop
      Value := Coprime (First (Pair), Second (Pair));
      Silver_IO.Put
         ("coprime(" & Integer'Image (First (Pair)) & "," &
          Integer'Image (Second (Pair)) & ") = ");
      if Value then
         Silver_IO.Put_Line ("true");
      else
         Silver_IO.Put_Line ("false");
      end if;
   end loop;
end Main;
