with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Candidate is Integer range 0 .. 499;
   subtype Digit_Total is Integer range 0 .. 27;

   function Is_Prime (N : in Candidate) return Boolean is
      Prime : Boolean := False;
   begin
      if N >= 2 then
         Prime := True;
         for Divisor in 2 .. (N / 2) loop
            if (N mod Divisor) = 0 then
               Prime := False;
            end if;
         end loop;
      end if;
      return Prime;
   end Is_Prime;

   function Digit_Sum (N : in Candidate) return Digit_Total is
      Remaining : Candidate := 0;
      Total : Digit_Total := 0;
   begin
      Remaining := N;
      -- Three decimal digits suffice for the entire 0 .. 499 domain.
      for Digit in 1 .. 3 loop
         -- At most two earlier digits contribute at most 18.
         if Total <= 18 then
            Total := (Total + (Remaining mod 10));
         end if;
         Remaining := (Remaining / 10);
      end loop;
      return Total;
   end Digit_Sum;

   Prime : Boolean := False;
   Digit_Prime : Boolean := False;
   Sum : Digit_Total := 0;
begin
   for N in 2 .. 499 loop
      Prime := Is_Prime (N);
      Sum := Digit_Sum (N);
      Digit_Prime := Is_Prime (Sum);
      if Prime and then Digit_Prime then
         Silver_IO.Put_Line (Integer'Image (N));
      end if;
   end loop;
end Main;
