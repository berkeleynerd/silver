procedure Main is
 pragma SPARK_Mode (On);
begin
 for I in 1 .. 0 loop
  if (I rem 0) = 0 then null; end if;
 end loop;
end Main;
