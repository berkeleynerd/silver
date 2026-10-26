procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   D : Integer range -1 .. 1 := 0;
   Q : Integer range -9 .. 9 := 0;
   Source : Integer range 0 .. 9 := 0;
   Snapshot : constant Integer := Source;
begin
   for Seed in -1 .. 1 loop
      D := Seed;
      if D /= 0 then Q := (9 / D); end if;
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 2 then
         for I in 2 .. X loop X := I; end loop;
      end if;
      if X = 10 then X := X; end if;
   end loop;
   for I in 0 .. 9 loop
      if I > Snapshot then Q := (9 / I); end if;
   end loop;
end Main;
