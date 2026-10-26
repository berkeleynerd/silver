procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   Positive : Integer range 1 .. 9 := 1;
   Below : Integer range 0 .. 8 := 0;
   Exact : Integer range 5 .. 5 := 5;
begin
   for Seed in 0 .. 9 loop
      X := Seed;
      if X = 5 then Exact := X; end if;
      if X /= 0 then Positive := X; end if;
      if X < 9 then Below := X; end if;
      if X <= 8 then Below := X; end if;
      if X > 0 then Positive := X; end if;
      if X >= 1 then Positive := X; end if;
      if 5 = X then Exact := X; end if;
      if 0 /= X then Positive := X; end if;
      if 9 > X then Below := X; end if;
      if 8 >= X then Below := X; end if;
      if 0 < X then Positive := X; end if;
      if 1 <= X then Positive := X; end if;
      if X = 0 then null; else Positive := X; end if;
      if X /= 5 then null; else Exact := X; end if;
      if X < 1 then null; else Positive := X; end if;
      if X <= 0 then null; else Positive := X; end if;
      if X > 8 then null; else Below := X; end if;
      if X >= 9 then null; else Below := X; end if;
      if 0 = X then null; else Positive := X; end if;
      if 5 /= X then null; else Exact := X; end if;
      if 1 > X then null; else Positive := X; end if;
      if 0 >= X then null; else Positive := X; end if;
      if 8 < X then null; else Below := X; end if;
      if 9 <= X then null; else Below := X; end if;
   end loop;
end Main;
