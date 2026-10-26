procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   Wide : Integer := 0;
   Negated : Integer := 0;
begin
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then
         X := 9;
         X := (X + 1);
      end if;
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then X := 0; else X := 9; end if;
      X := (X + 1);
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then X := 0; end if;
      X := (X + 1);
   end loop;
   for Seed in 0 .. 8 loop
      X := Seed;
      if X < 9 then
         for Step in 1 .. 2 loop X := (X + 1); end loop;
      end if;
   end loop;
   for Seed in -2147483648 .. -2147483647 loop
      Wide := Seed;
      if Wide < 0 then Negated := (-Wide); end if;
   end loop;
   for Seed in 0 .. 20 loop
      Wide := Seed;
      for Wide in 1 .. 2 loop null; end loop;
      X := Wide;
   end loop;
end Main;
