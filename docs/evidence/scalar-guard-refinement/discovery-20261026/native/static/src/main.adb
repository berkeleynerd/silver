procedure Main is
   pragma SPARK_Mode (On);
   Max : constant Integer := 2147483647;
   Min : constant Integer := -2147483648;
   Value : Integer := 0;
begin
   if Max < 0 then Value := (Max + 1); end if;
   if Min > 0 then Value := (-Min); end if;
end Main;
