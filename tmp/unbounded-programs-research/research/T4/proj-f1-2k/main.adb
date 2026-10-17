with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A0 : Integer range 0 .. 9 := 3;
   B0 : Integer range -5 .. 5 := 0;
   C0 : constant Integer := A0;
   S0 : String := "abc";
   A1 : Integer range 0 .. 9 := 3;
   B1 : Integer range -5 .. 5 := 0;
   C1 : constant Integer := A1;
   S1 : String := "abc";
   A2 : Integer range 0 .. 9 := 3;
   B2 : Integer range -5 .. 5 := 0;
   C2 : constant Integer := A2;
   S2 : String := "abc";
begin
   A0 := (9 - A0);
   B0 := (-B0);
   if A0 > C0 then
      S0 := "xyz";
   elsif A0 = 0 then
      B0 := 5;
   else
      S0 := "abc";
   end if;
   for I0 in 1 .. 3 loop
      for J0 in 0 .. I0 loop
         Silver_IO.Put (Integer'Image ((I0 * J0)));
      end loop;
      B0 := (I0 - 3);
   end loop;
   A0 := 7;
   Silver_IO.Put_Line (S0 & Integer'Image (B0));
   A1 := (9 - A1);
   B1 := (-B1);
   if A1 > C1 then
      S1 := "xyz";
   elsif A1 = 0 then
      B1 := 5;
   else
      S1 := "abc";
   end if;
   for I1 in 1 .. 3 loop
      for J1 in 0 .. I1 loop
         Silver_IO.Put (Integer'Image ((I1 * J1)));
      end loop;
      B1 := (I1 - 3);
   end loop;
   A1 := 7;
   Silver_IO.Put_Line (S1 & Integer'Image (B1));
   A2 := (9 - A2);
   B2 := (-B2);
   if A2 > C2 then
      S2 := "xyz";
   elsif A2 = 0 then
      B2 := 5;
   else
      S2 := "abc";
   end if;
   for I2 in 1 .. 3 loop
      for J2 in 0 .. I2 loop
         Silver_IO.Put (Integer'Image ((I2 * J2)));
      end loop;
      B2 := (I2 - 3);
   end loop;
   A2 := 7;
   Silver_IO.Put_Line (S2 & Integer'Image (B2));
end Main;
