procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 20 := 0;
   Small : Integer range 0 .. 9 := 0;
   Visits : Integer range 0 .. 100 := 0;
   Other : Integer range 0 .. 20 := 0;
   Text : String := "x";
begin
   for Step in 1 .. 100 loop
      if Visits < 100 then Visits := (Visits + 1); end if;
   end loop;
   for Seed in 0 .. 20 loop
      X := Seed;
      if X < 9 then
         X := 9;
         Small := (9 - X);
      end if;
      X := Seed;
      if X < 9 then
         Other := 20;
         Text := "y";
         Small := X;
      end if;
      X := Seed;
      if X < 9 then X := 1; else X := 2; end if;
      Small := X;
      X := Seed;
      if X <= 9 then
         for I in 1 .. X loop
            X := 20;
            Small := I;
         end loop;
      end if;
      for X in 0 .. 20 loop
         if X <= 9 then
            for X in 1 .. 2 loop Small := X; end loop;
            Small := X;
         end if;
      end loop;
      X := 1;
      for I in 2 .. X loop null; end loop;
      Small := X;
   end loop;
end Main;
