with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Candidate is Integer range -10 .. 100;

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

   Prime : Boolean := False;
begin
   for N in -10 .. 100 loop
      Prime := Is_Prime (N);
      if Prime then
         Silver_IO.Put_Line (Integer'Image (N));
      end if;
   end loop;
end Main;
