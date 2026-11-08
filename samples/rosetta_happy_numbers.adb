with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Decimal_Input is Integer range 0 .. 999;
   subtype Square_Sum_Value is Integer range 0 .. 243;

   function Sum_Squared_Digits (N : in Decimal_Input)
      return Square_Sum_Value is
      Remaining : Decimal_Input := 0;
      Digit : Integer range 0 .. 9 := 0;
      Total : Square_Sum_Value := 0;
   begin
      Remaining := N;
      for Position in 1 .. 3 loop
         Digit := (Remaining mod 10);
         -- At most two earlier squares, each at most 81, precede addition.
         if Total <= 162 then
            Total := (Total + (Digit * Digit));
         end if;
         Remaining := (Remaining / 10);
      end loop;
      return Total;
   end Sum_Squared_Digits;

   function Is_Happy (N : in Decimal_Input) return Boolean is
      Current : Decimal_Input := 0;
   begin
      Current := N;
      -- The first image enters 0..243; 1 is absorbing. If 244 images
      -- avoid 1, two are the same non-1 state and no later image is 1.
      for Step in 1 .. 244 loop
         Current := Sum_Squared_Digits (Current);
      end loop;
      return Current = 1;
   end Is_Happy;

   Happy : Boolean := False;
begin
   -- The complete prefix through 31 contains exactly eight happy numbers.
   for Candidate in 1 .. 31 loop
      Happy := Is_Happy (Candidate);
      if Happy then
         Silver_IO.Put_Line (Integer'Image (Candidate));
      end if;
   end loop;
end Main;
