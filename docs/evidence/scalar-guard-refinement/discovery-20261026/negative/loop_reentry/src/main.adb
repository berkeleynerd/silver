procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
begin
   for Seed in 0 .. 8 loop
      X := Seed;
      if X < 9 then
         for Step in 1 .. 2 loop X := (X + 1); end loop;
      end if;
   end loop;
end Main;
