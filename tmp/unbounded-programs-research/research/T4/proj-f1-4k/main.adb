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
   A3 : Integer range 0 .. 9 := 3;
   B3 : Integer range -5 .. 5 := 0;
   C3 : constant Integer := A3;
   S3 : String := "abc";
   A4 : Integer range 0 .. 9 := 3;
   B4 : Integer range -5 .. 5 := 0;
   C4 : constant Integer := A4;
   S4 : String := "abc";
   A5 : Integer range 0 .. 9 := 3;
   B5 : Integer range -5 .. 5 := 0;
   C5 : constant Integer := A5;
   S5 : String := "abc";
   A6 : Integer range 0 .. 9 := 3;
   B6 : Integer range -5 .. 5 := 0;
   C6 : constant Integer := A6;
   S6 : String := "abc";
   A7 : Integer range 0 .. 9 := 3;
   B7 : Integer range -5 .. 5 := 0;
   C7 : constant Integer := A7;
   S7 : String := "abc";
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
   A3 := (9 - A3);
   B3 := (-B3);
   if A3 > C3 then
      S3 := "xyz";
   elsif A3 = 0 then
      B3 := 5;
   else
      S3 := "abc";
   end if;
   for I3 in 1 .. 3 loop
      for J3 in 0 .. I3 loop
         Silver_IO.Put (Integer'Image ((I3 * J3)));
      end loop;
      B3 := (I3 - 3);
   end loop;
   A3 := 7;
   Silver_IO.Put_Line (S3 & Integer'Image (B3));
   A4 := (9 - A4);
   B4 := (-B4);
   if A4 > C4 then
      S4 := "xyz";
   elsif A4 = 0 then
      B4 := 5;
   else
      S4 := "abc";
   end if;
   for I4 in 1 .. 3 loop
      for J4 in 0 .. I4 loop
         Silver_IO.Put (Integer'Image ((I4 * J4)));
      end loop;
      B4 := (I4 - 3);
   end loop;
   A4 := 7;
   Silver_IO.Put_Line (S4 & Integer'Image (B4));
   A5 := (9 - A5);
   B5 := (-B5);
   if A5 > C5 then
      S5 := "xyz";
   elsif A5 = 0 then
      B5 := 5;
   else
      S5 := "abc";
   end if;
   for I5 in 1 .. 3 loop
      for J5 in 0 .. I5 loop
         Silver_IO.Put (Integer'Image ((I5 * J5)));
      end loop;
      B5 := (I5 - 3);
   end loop;
   A5 := 7;
   Silver_IO.Put_Line (S5 & Integer'Image (B5));
   A6 := (9 - A6);
   B6 := (-B6);
   if A6 > C6 then
      S6 := "xyz";
   elsif A6 = 0 then
      B6 := 5;
   else
      S6 := "abc";
   end if;
   for I6 in 1 .. 3 loop
      for J6 in 0 .. I6 loop
         Silver_IO.Put (Integer'Image ((I6 * J6)));
      end loop;
      B6 := (I6 - 3);
   end loop;
   A6 := 7;
   Silver_IO.Put_Line (S6 & Integer'Image (B6));
   A7 := (9 - A7);
   B7 := (-B7);
   if A7 > C7 then
      S7 := "xyz";
   elsif A7 = 0 then
      B7 := 5;
   else
      S7 := "abc";
   end if;
   for I7 in 1 .. 3 loop
      for J7 in 0 .. I7 loop
         Silver_IO.Put (Integer'Image ((I7 * J7)));
      end loop;
      B7 := (I7 - 3);
   end loop;
   A7 := 7;
   Silver_IO.Put_Line (S7 & Integer'Image (B7));
end Main;
