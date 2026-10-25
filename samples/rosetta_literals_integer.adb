with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- A base B is any decimal integer from 2 through 16: B#digits# or B:digits:.
   -- Digits 0 .. B-1 are used; A .. F denote 10 .. 15 without case distinctions.
   -- An optional nonnegative E exponent multiplies the value by B**exponent.
   -- The first seven examples below are 727; 7#1#E3 is 343, not 727.
   -- Underscores separate digits. Silver has one predefined signed Integer type.
   Binary : constant Integer := 2#10_1101_0111#;
   Octal : constant Integer := 8#1_327#;
   Decimal : constant Integer := 10#727#;
   Hex : constant Integer := 16#2D7#;
   Colon : constant Integer := 16:2d7:;
   Grouped : constant Integer := 7_27;
   Exponent : constant Integer := 727E0;
   Base_7 : constant Integer := 7#1#E3;
   Smallest : constant Integer := -2_147_483_648;
   Largest : constant Integer := 2_147_483_647;
begin
   Silver_IO.Put_Line ("2#10_1101_0111# =" & Integer'Image (Binary));
   Silver_IO.Put_Line ("8#1_327# =" & Integer'Image (Octal));
   Silver_IO.Put_Line ("10#727# =" & Integer'Image (Decimal));
   Silver_IO.Put_Line ("16#2D7# =" & Integer'Image (Hex));
   Silver_IO.Put_Line ("16:2d7: =" & Integer'Image (Colon));
   Silver_IO.Put_Line ("7_27 =" & Integer'Image (Grouped));
   Silver_IO.Put_Line ("727E0 =" & Integer'Image (Exponent));
   Silver_IO.Put_Line ("7#1#E3 =" & Integer'Image (Base_7));
   Silver_IO.Put_Line ("Integer spans " & Integer'Image (Smallest) & " .." & Integer'Image (Largest));
end Main;
