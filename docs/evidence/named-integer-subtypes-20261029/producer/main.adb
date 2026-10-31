procedure Main is
   pragma SPARK_Mode (On);
   subtype Small is Integer range -9 .. 9;
   Limit : constant Small := 9;
   subtype Natural_Small is Integer range 0 .. Limit;
   X : Small := 3;
   Y : Natural_Small range 1 .. 7 := 3;
   Snapshot : constant Natural_Small := Y;
   Data : constant array (-1 .. 1) of Small := (-3, 0, 4);
   Work : array (1 .. 2) of Small := (X, Snapshot);
   Total : Integer range 0 .. 1000 := 0;
begin
   for E of Data loop
      if Total <= 919 then
         Total := (Total + (E * E));
      end if;
   end loop;
   for I in 1 .. 2 loop
      Work (I) := X;
   end loop;
   X := Work (1);
   if X >= 1 and then X <= 7 then
      Y := X;
   end if;
end Main;
