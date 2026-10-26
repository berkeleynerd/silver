procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
begin
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then
         X := 9;
         X := (X + 1);
      end if;
   end loop;
end Main;
