with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Natural_Input is Integer range 0 .. 2_147_483_647;
   subtype Numeral_Base is Integer range 2 .. 36;
   subtype Digit_Sum_Value is Integer range 0 .. 1085;

   function Sum_Digits (N : in Natural_Input; Base : in Numeral_Base)
      return Digit_Sum_Value is
      Remaining : Natural_Input := 0;
      Digit : Integer range 0 .. 35 := 0;
      Total : Digit_Sum_Value := 0;
   begin
      Remaining := N;
      -- Every input has at most 31 digits, since Base is at least 2.
      for Position in 1 .. 31 loop
         Digit := (Remaining mod Base);
         -- At most 30 earlier digits, each at most 35, precede an addition.
         if Total <= 1050 then
            Total := (Total + Digit);
         end if;
         Remaining := (Remaining / Base);
      end loop;
      return Total;
   end Sum_Digits;

   -- Decimal 254 and 3854 are the task's hexadecimal FE and F0E.
   Inputs : constant array (1 .. 17) of Natural_Input :=
      (1, 1234, 254, 3854, 0, 1, 2, 3, 0, 35, 36, 1295, 1296,
       2_147_483_647, 2_147_483_647, 2_147_483_647, 2_147_483_647);
   Bases : constant array (1 .. 17) of Numeral_Base :=
      (10, 10, 16, 16, 2, 2, 2, 2, 36, 36, 36, 36, 36, 2, 10, 16, 36);
   Value : Digit_Sum_Value := 0;
begin
   for Case_Index in 1 .. 17 loop
      Value := Sum_Digits (Inputs (Case_Index), Bases (Case_Index));
      Silver_IO.Put_Line
         ("sum_digits(" & Integer'Image (Inputs (Case_Index)) & "," &
          Integer'Image (Bases (Case_Index)) & ") =" & Integer'Image (Value));
   end loop;
end Main;
