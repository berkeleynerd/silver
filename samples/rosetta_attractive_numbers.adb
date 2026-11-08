with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Candidate is Integer range 0 .. 120;
   subtype Positive_Input is Integer range 1 .. 120;
   subtype Factor_Count is Integer range 0 .. 6;

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

   function Prime_Factor_Count (N : in Positive_Input) return Factor_Count is
      Remaining : Candidate := 0;
      Count : Factor_Count := 0;
   begin
      Remaining := N;
      for Factor in 2 .. 120 loop
         -- Seven successes would require N >= 2 ** 7 = 128.
         for Attempt in 1 .. 7 loop
            if Remaining > 1 and then (Remaining mod Factor) = 0 then
               if Count < 6 then
                  Remaining := (Remaining / Factor);
                  Count := (Count + 1);
               end if;
            end if;
         end loop;
      end loop;
      return Count;
   end Prime_Factor_Count;

   Count : Factor_Count := 0;
   Attractive : Boolean := False;
begin
   for N in 1 .. 120 loop
      Count := Prime_Factor_Count (N);
      Attractive := Is_Prime (Count);
      if Attractive then
         Silver_IO.Put_Line (Integer'Image (N));
      end if;
   end loop;
end Main;
