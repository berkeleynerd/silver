with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Limit : constant Integer := 100;
   Prime : array (2 .. Limit) of Boolean :=
      (True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True, True,
       True, True, True, True, True, True, True, True, True);
   Multiple : Integer range 4 .. 500 := 4;
begin
   for Base in 2 .. 10 loop
      if Prime (Base) then
         for K in Base .. (Limit / Base) loop
            Multiple := (K * Base);
            if Multiple <= Limit then
               Prime (Multiple) := False;
            end if;
         end loop;
      end if;
   end loop;
   for Candidate in 2 .. Limit loop
      if Prime (Candidate) then
         Silver_IO.Put_Line (Integer'Image (Candidate));
      end if;
   end loop;
end Main;
