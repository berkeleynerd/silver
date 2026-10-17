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
   A8 : Integer range 0 .. 9 := 3;
   B8 : Integer range -5 .. 5 := 0;
   C8 : constant Integer := A8;
   S8 : String := "abc";
   A9 : Integer range 0 .. 9 := 3;
   B9 : Integer range -5 .. 5 := 0;
   C9 : constant Integer := A9;
   S9 : String := "abc";
   A10 : Integer range 0 .. 9 := 3;
   B10 : Integer range -5 .. 5 := 0;
   C10 : constant Integer := A10;
   S10 : String := "abc";
   A11 : Integer range 0 .. 9 := 3;
   B11 : Integer range -5 .. 5 := 0;
   C11 : constant Integer := A11;
   S11 : String := "abc";
   A12 : Integer range 0 .. 9 := 3;
   B12 : Integer range -5 .. 5 := 0;
   C12 : constant Integer := A12;
   S12 : String := "abc";
   A13 : Integer range 0 .. 9 := 3;
   B13 : Integer range -5 .. 5 := 0;
   C13 : constant Integer := A13;
   S13 : String := "abc";
   A14 : Integer range 0 .. 9 := 3;
   B14 : Integer range -5 .. 5 := 0;
   C14 : constant Integer := A14;
   S14 : String := "abc";
   A15 : Integer range 0 .. 9 := 3;
   B15 : Integer range -5 .. 5 := 0;
   C15 : constant Integer := A15;
   S15 : String := "abc";
   A16 : Integer range 0 .. 9 := 3;
   B16 : Integer range -5 .. 5 := 0;
   C16 : constant Integer := A16;
   S16 : String := "abc";
   A17 : Integer range 0 .. 9 := 3;
   B17 : Integer range -5 .. 5 := 0;
   C17 : constant Integer := A17;
   S17 : String := "abc";
   A18 : Integer range 0 .. 9 := 3;
   B18 : Integer range -5 .. 5 := 0;
   C18 : constant Integer := A18;
   S18 : String := "abc";
   A19 : Integer range 0 .. 9 := 3;
   B19 : Integer range -5 .. 5 := 0;
   C19 : constant Integer := A19;
   S19 : String := "abc";
   A20 : Integer range 0 .. 9 := 3;
   B20 : Integer range -5 .. 5 := 0;
   C20 : constant Integer := A20;
   S20 : String := "abc";
   A21 : Integer range 0 .. 9 := 3;
   B21 : Integer range -5 .. 5 := 0;
   C21 : constant Integer := A21;
   S21 : String := "abc";
   A22 : Integer range 0 .. 9 := 3;
   B22 : Integer range -5 .. 5 := 0;
   C22 : constant Integer := A22;
   S22 : String := "abc";
   A23 : Integer range 0 .. 9 := 3;
   B23 : Integer range -5 .. 5 := 0;
   C23 : constant Integer := A23;
   S23 : String := "abc";
   A24 : Integer range 0 .. 9 := 3;
   B24 : Integer range -5 .. 5 := 0;
   C24 : constant Integer := A24;
   S24 : String := "abc";
   A25 : Integer range 0 .. 9 := 3;
   B25 : Integer range -5 .. 5 := 0;
   C25 : constant Integer := A25;
   S25 : String := "abc";
   A26 : Integer range 0 .. 9 := 3;
   B26 : Integer range -5 .. 5 := 0;
   C26 : constant Integer := A26;
   S26 : String := "abc";
   A27 : Integer range 0 .. 9 := 3;
   B27 : Integer range -5 .. 5 := 0;
   C27 : constant Integer := A27;
   S27 : String := "abc";
   A28 : Integer range 0 .. 9 := 3;
   B28 : Integer range -5 .. 5 := 0;
   C28 : constant Integer := A28;
   S28 : String := "abc";
   A29 : Integer range 0 .. 9 := 3;
   B29 : Integer range -5 .. 5 := 0;
   C29 : constant Integer := A29;
   S29 : String := "abc";
   A30 : Integer range 0 .. 9 := 3;
   B30 : Integer range -5 .. 5 := 0;
   C30 : constant Integer := A30;
   S30 : String := "abc";
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
   A8 := (9 - A8);
   B8 := (-B8);
   if A8 > C8 then
      S8 := "xyz";
   elsif A8 = 0 then
      B8 := 5;
   else
      S8 := "abc";
   end if;
   for I8 in 1 .. 3 loop
      for J8 in 0 .. I8 loop
         Silver_IO.Put (Integer'Image ((I8 * J8)));
      end loop;
      B8 := (I8 - 3);
   end loop;
   A8 := 7;
   Silver_IO.Put_Line (S8 & Integer'Image (B8));
   A9 := (9 - A9);
   B9 := (-B9);
   if A9 > C9 then
      S9 := "xyz";
   elsif A9 = 0 then
      B9 := 5;
   else
      S9 := "abc";
   end if;
   for I9 in 1 .. 3 loop
      for J9 in 0 .. I9 loop
         Silver_IO.Put (Integer'Image ((I9 * J9)));
      end loop;
      B9 := (I9 - 3);
   end loop;
   A9 := 7;
   Silver_IO.Put_Line (S9 & Integer'Image (B9));
   A10 := (9 - A10);
   B10 := (-B10);
   if A10 > C10 then
      S10 := "xyz";
   elsif A10 = 0 then
      B10 := 5;
   else
      S10 := "abc";
   end if;
   for I10 in 1 .. 3 loop
      for J10 in 0 .. I10 loop
         Silver_IO.Put (Integer'Image ((I10 * J10)));
      end loop;
      B10 := (I10 - 3);
   end loop;
   A10 := 7;
   Silver_IO.Put_Line (S10 & Integer'Image (B10));
   A11 := (9 - A11);
   B11 := (-B11);
   if A11 > C11 then
      S11 := "xyz";
   elsif A11 = 0 then
      B11 := 5;
   else
      S11 := "abc";
   end if;
   for I11 in 1 .. 3 loop
      for J11 in 0 .. I11 loop
         Silver_IO.Put (Integer'Image ((I11 * J11)));
      end loop;
      B11 := (I11 - 3);
   end loop;
   A11 := 7;
   Silver_IO.Put_Line (S11 & Integer'Image (B11));
   A12 := (9 - A12);
   B12 := (-B12);
   if A12 > C12 then
      S12 := "xyz";
   elsif A12 = 0 then
      B12 := 5;
   else
      S12 := "abc";
   end if;
   for I12 in 1 .. 3 loop
      for J12 in 0 .. I12 loop
         Silver_IO.Put (Integer'Image ((I12 * J12)));
      end loop;
      B12 := (I12 - 3);
   end loop;
   A12 := 7;
   Silver_IO.Put_Line (S12 & Integer'Image (B12));
   A13 := (9 - A13);
   B13 := (-B13);
   if A13 > C13 then
      S13 := "xyz";
   elsif A13 = 0 then
      B13 := 5;
   else
      S13 := "abc";
   end if;
   for I13 in 1 .. 3 loop
      for J13 in 0 .. I13 loop
         Silver_IO.Put (Integer'Image ((I13 * J13)));
      end loop;
      B13 := (I13 - 3);
   end loop;
   A13 := 7;
   Silver_IO.Put_Line (S13 & Integer'Image (B13));
   A14 := (9 - A14);
   B14 := (-B14);
   if A14 > C14 then
      S14 := "xyz";
   elsif A14 = 0 then
      B14 := 5;
   else
      S14 := "abc";
   end if;
   for I14 in 1 .. 3 loop
      for J14 in 0 .. I14 loop
         Silver_IO.Put (Integer'Image ((I14 * J14)));
      end loop;
      B14 := (I14 - 3);
   end loop;
   A14 := 7;
   Silver_IO.Put_Line (S14 & Integer'Image (B14));
   A15 := (9 - A15);
   B15 := (-B15);
   if A15 > C15 then
      S15 := "xyz";
   elsif A15 = 0 then
      B15 := 5;
   else
      S15 := "abc";
   end if;
   for I15 in 1 .. 3 loop
      for J15 in 0 .. I15 loop
         Silver_IO.Put (Integer'Image ((I15 * J15)));
      end loop;
      B15 := (I15 - 3);
   end loop;
   A15 := 7;
   Silver_IO.Put_Line (S15 & Integer'Image (B15));
   A16 := (9 - A16);
   B16 := (-B16);
   if A16 > C16 then
      S16 := "xyz";
   elsif A16 = 0 then
      B16 := 5;
   else
      S16 := "abc";
   end if;
   for I16 in 1 .. 3 loop
      for J16 in 0 .. I16 loop
         Silver_IO.Put (Integer'Image ((I16 * J16)));
      end loop;
      B16 := (I16 - 3);
   end loop;
   A16 := 7;
   Silver_IO.Put_Line (S16 & Integer'Image (B16));
   A17 := (9 - A17);
   B17 := (-B17);
   if A17 > C17 then
      S17 := "xyz";
   elsif A17 = 0 then
      B17 := 5;
   else
      S17 := "abc";
   end if;
   for I17 in 1 .. 3 loop
      for J17 in 0 .. I17 loop
         Silver_IO.Put (Integer'Image ((I17 * J17)));
      end loop;
      B17 := (I17 - 3);
   end loop;
   A17 := 7;
   Silver_IO.Put_Line (S17 & Integer'Image (B17));
   A18 := (9 - A18);
   B18 := (-B18);
   if A18 > C18 then
      S18 := "xyz";
   elsif A18 = 0 then
      B18 := 5;
   else
      S18 := "abc";
   end if;
   for I18 in 1 .. 3 loop
      for J18 in 0 .. I18 loop
         Silver_IO.Put (Integer'Image ((I18 * J18)));
      end loop;
      B18 := (I18 - 3);
   end loop;
   A18 := 7;
   Silver_IO.Put_Line (S18 & Integer'Image (B18));
   A19 := (9 - A19);
   B19 := (-B19);
   if A19 > C19 then
      S19 := "xyz";
   elsif A19 = 0 then
      B19 := 5;
   else
      S19 := "abc";
   end if;
   for I19 in 1 .. 3 loop
      for J19 in 0 .. I19 loop
         Silver_IO.Put (Integer'Image ((I19 * J19)));
      end loop;
      B19 := (I19 - 3);
   end loop;
   A19 := 7;
   Silver_IO.Put_Line (S19 & Integer'Image (B19));
   A20 := (9 - A20);
   B20 := (-B20);
   if A20 > C20 then
      S20 := "xyz";
   elsif A20 = 0 then
      B20 := 5;
   else
      S20 := "abc";
   end if;
   for I20 in 1 .. 3 loop
      for J20 in 0 .. I20 loop
         Silver_IO.Put (Integer'Image ((I20 * J20)));
      end loop;
      B20 := (I20 - 3);
   end loop;
   A20 := 7;
   Silver_IO.Put_Line (S20 & Integer'Image (B20));
   A21 := (9 - A21);
   B21 := (-B21);
   if A21 > C21 then
      S21 := "xyz";
   elsif A21 = 0 then
      B21 := 5;
   else
      S21 := "abc";
   end if;
   for I21 in 1 .. 3 loop
      for J21 in 0 .. I21 loop
         Silver_IO.Put (Integer'Image ((I21 * J21)));
      end loop;
      B21 := (I21 - 3);
   end loop;
   A21 := 7;
   Silver_IO.Put_Line (S21 & Integer'Image (B21));
   A22 := (9 - A22);
   B22 := (-B22);
   if A22 > C22 then
      S22 := "xyz";
   elsif A22 = 0 then
      B22 := 5;
   else
      S22 := "abc";
   end if;
   for I22 in 1 .. 3 loop
      for J22 in 0 .. I22 loop
         Silver_IO.Put (Integer'Image ((I22 * J22)));
      end loop;
      B22 := (I22 - 3);
   end loop;
   A22 := 7;
   Silver_IO.Put_Line (S22 & Integer'Image (B22));
   A23 := (9 - A23);
   B23 := (-B23);
   if A23 > C23 then
      S23 := "xyz";
   elsif A23 = 0 then
      B23 := 5;
   else
      S23 := "abc";
   end if;
   for I23 in 1 .. 3 loop
      for J23 in 0 .. I23 loop
         Silver_IO.Put (Integer'Image ((I23 * J23)));
      end loop;
      B23 := (I23 - 3);
   end loop;
   A23 := 7;
   Silver_IO.Put_Line (S23 & Integer'Image (B23));
   A24 := (9 - A24);
   B24 := (-B24);
   if A24 > C24 then
      S24 := "xyz";
   elsif A24 = 0 then
      B24 := 5;
   else
      S24 := "abc";
   end if;
   for I24 in 1 .. 3 loop
      for J24 in 0 .. I24 loop
         Silver_IO.Put (Integer'Image ((I24 * J24)));
      end loop;
      B24 := (I24 - 3);
   end loop;
   A24 := 7;
   Silver_IO.Put_Line (S24 & Integer'Image (B24));
   A25 := (9 - A25);
   B25 := (-B25);
   if A25 > C25 then
      S25 := "xyz";
   elsif A25 = 0 then
      B25 := 5;
   else
      S25 := "abc";
   end if;
   for I25 in 1 .. 3 loop
      for J25 in 0 .. I25 loop
         Silver_IO.Put (Integer'Image ((I25 * J25)));
      end loop;
      B25 := (I25 - 3);
   end loop;
   A25 := 7;
   Silver_IO.Put_Line (S25 & Integer'Image (B25));
   A26 := (9 - A26);
   B26 := (-B26);
   if A26 > C26 then
      S26 := "xyz";
   elsif A26 = 0 then
      B26 := 5;
   else
      S26 := "abc";
   end if;
   for I26 in 1 .. 3 loop
      for J26 in 0 .. I26 loop
         Silver_IO.Put (Integer'Image ((I26 * J26)));
      end loop;
      B26 := (I26 - 3);
   end loop;
   A26 := 7;
   Silver_IO.Put_Line (S26 & Integer'Image (B26));
   A27 := (9 - A27);
   B27 := (-B27);
   if A27 > C27 then
      S27 := "xyz";
   elsif A27 = 0 then
      B27 := 5;
   else
      S27 := "abc";
   end if;
   for I27 in 1 .. 3 loop
      for J27 in 0 .. I27 loop
         Silver_IO.Put (Integer'Image ((I27 * J27)));
      end loop;
      B27 := (I27 - 3);
   end loop;
   A27 := 7;
   Silver_IO.Put_Line (S27 & Integer'Image (B27));
   A28 := (9 - A28);
   B28 := (-B28);
   if A28 > C28 then
      S28 := "xyz";
   elsif A28 = 0 then
      B28 := 5;
   else
      S28 := "abc";
   end if;
   for I28 in 1 .. 3 loop
      for J28 in 0 .. I28 loop
         Silver_IO.Put (Integer'Image ((I28 * J28)));
      end loop;
      B28 := (I28 - 3);
   end loop;
   A28 := 7;
   Silver_IO.Put_Line (S28 & Integer'Image (B28));
   A29 := (9 - A29);
   B29 := (-B29);
   if A29 > C29 then
      S29 := "xyz";
   elsif A29 = 0 then
      B29 := 5;
   else
      S29 := "abc";
   end if;
   for I29 in 1 .. 3 loop
      for J29 in 0 .. I29 loop
         Silver_IO.Put (Integer'Image ((I29 * J29)));
      end loop;
      B29 := (I29 - 3);
   end loop;
   A29 := 7;
   Silver_IO.Put_Line (S29 & Integer'Image (B29));
   A30 := (9 - A30);
   B30 := (-B30);
   if A30 > C30 then
      S30 := "xyz";
   elsif A30 = 0 then
      B30 := 5;
   else
      S30 := "abc";
   end if;
   for I30 in 1 .. 3 loop
      for J30 in 0 .. I30 loop
         Silver_IO.Put (Integer'Image ((I30 * J30)));
      end loop;
      B30 := (I30 - 3);
   end loop;
   A30 := 7;
   Silver_IO.Put_Line (S30 & Integer'Image (B30));
end Main;
