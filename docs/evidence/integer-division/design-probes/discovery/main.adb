procedure Main is
   pragma SPARK_Mode (On);
   Q : Integer range -9 .. 9 := 0;
   R : Integer range -2 .. 2 := 0;
   P : Integer range 0 .. 2 := 0;
   N : Integer range -2 .. 0 := 0;
   Static_Rem : constant Integer := (-2147483648 rem (-1));
   Static_Mod : constant Integer := (-2147483648 mod (-1));
begin
   for A in -9 .. 9 loop
      for D in 1 .. 3 loop
         Q := (A / D);
         R := (A rem D);
         P := (A mod D);
      end loop;
      for D in -3 .. -1 loop
         Q := (A / D);
         R := (A rem D);
         N := (A mod D);
      end loop;
   end loop;
   for A in -2147483648 .. -2147483647 loop
      for D in -2 .. -1 loop
         R := (A rem D);
         N := (A mod D);
      end loop;
   end loop;
end Main;
