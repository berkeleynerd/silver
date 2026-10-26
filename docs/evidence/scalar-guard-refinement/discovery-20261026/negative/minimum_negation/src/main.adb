procedure Main is
   pragma SPARK_Mode (On);
   Wide : Integer := 0;
   Negated : Integer := 0;
begin
   for Seed in -2147483648 .. -2147483647 loop
      Wide := Seed;
      if Wide < 0 then Negated := (-Wide); end if;
   end loop;
end Main;
