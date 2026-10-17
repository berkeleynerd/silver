with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A0 : constant String := "x";
   A1 : constant String := A0 & A0;
   A2 : constant String := A1 & A1;
   A3 : constant String := A2 & A2;
   A4 : constant String := A3 & A3;
   A5 : constant String := A4 & A4;
   A6 : constant String := A5 & A5;
   A7 : constant String := A6 & A6;
   A8 : constant String := A7 & A7;
   A9 : constant String := A8 & A8;
   A10 : constant String := A9 & A9;
   A11 : constant String := A10 & A10;
   A12 : constant String := A11 & A11;
   A13 : constant String := A12 & A12;
   A14 : constant String := A13 & A13;
   A15 : constant String := A14 & A14;
   A16 : constant String := A15 & A15;
   A17 : constant String := A16 & A16;
   A18 : constant String := A17 & A17;
   A19 : constant String := A18 & A18;
   A20 : constant String := A19 & A19;
begin
   Silver_IO.Put_Line (A20);
end Main;
