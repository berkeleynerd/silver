with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Police Sanitation Fire");
   for Police in 1 .. 7 loop
      for Sanitation in 1 .. 7 loop
         for Fire in 1 .. 7 loop
            if (Police mod 2) = 0 and then Police /= Sanitation
              and then Police /= Fire and then Sanitation /= Fire
              and then ((Police + Sanitation) + Fire) = 12
            then
               Silver_IO.Put_Line
                 (Integer'Image (Police) & Integer'Image (Sanitation)
                  & Integer'Image (Fire));
            end if;
         end loop;
      end loop;
   end loop;
end Main;
