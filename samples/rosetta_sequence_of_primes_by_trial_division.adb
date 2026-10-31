with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Prime : Boolean := True;
begin
   for Candidate in 2 .. 100 loop
      Prime := True;
      for Divisor in 2 .. (Candidate - 1) loop
         if (Candidate mod Divisor) = 0 then
            Prime := False;
         end if;
      end loop;
      if Prime then
         Silver_IO.Put_Line (Integer'Image (Candidate));
      end if;
   end loop;
end Main;
