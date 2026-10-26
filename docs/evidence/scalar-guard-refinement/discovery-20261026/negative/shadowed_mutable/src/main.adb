procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   Wide : Integer := 0;
begin
   for Seed in 0 .. 20 loop
      Wide := Seed;
      for Wide in 1 .. 2 loop null; end loop;
      X := Wide;
   end loop;
end Main;
