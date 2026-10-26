procedure Main is
   pragma SPARK_Mode (On);
   Min : constant Integer := -2147483648;
   Max : constant Integer := 2147483647;
   Value : Integer := 0;
   D : Integer range 0 .. 9 := 0;
   Q : Integer range 0 .. 9 := 0;
begin
   for X in -2147483648 .. 2147483647 loop
      if X > Min then Value := (X - 1); end if;
      if Min < X then Value := (X - 1); end if;
      if X <= Min then null; else Value := (X - 1); end if;
      if X < Max then Value := (X + 1); end if;
      if Max > X then Value := (X + 1); end if;
      if X >= Max then null; else Value := (X + 1); end if;
      if X > Min then Value := (-X); end if;
      if X < Min then Value := X; end if;
      if X > Max then Value := X; end if;
   end loop;
   for Seed in 0 .. 9 loop
      D := Seed;
      if D > 0 and then (9 / D) > 0 then Q := (9 / D); end if;
      if D = 0 or else (9 / D) > 0 then null; end if;
      if not (D = 0) and then (9 / D) > 0 then null; end if;
      if D > 0 and then Integer'Image ((9 / D)) /= "" then null; end if;
   end loop;
end Main;
