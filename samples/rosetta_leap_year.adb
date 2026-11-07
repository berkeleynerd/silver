with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Gregorian_Year is Integer range 1 .. 2400;
   Years : constant array (1 .. 12) of Gregorian_Year :=
     (1600, 1700, 1800, 1900, 1996, 1999,
      2000, 2004, 2100, 2200, 2300, 2400);
begin
   for Year of Years loop
      Silver_IO.Put (Integer'Image (Year) & ": ");
      if (Year mod 400) = 0
        or else ((Year mod 4) = 0 and then (Year mod 100) /= 0)
      then
         Silver_IO.Put_Line ("leap");
      else
         Silver_IO.Put_Line ("common");
      end if;
   end loop;
end Main;
