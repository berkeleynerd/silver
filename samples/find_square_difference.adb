with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Answer : Integer range 0 .. 1000 := 0;
begin
   for N in 1 .. 1000 loop
      if Answer = 0 and then
        ((N * N) - ((N - 1) * (N - 1))) > 1000
      then
         Answer := N;
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Answer));
end Main;
