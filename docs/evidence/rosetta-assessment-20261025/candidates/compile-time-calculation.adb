with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- A static expression: Ada folds it at compile time and Silver admission
   -- computes the same exact value. 13! would exceed Integer and be rejected.
   Factorial_10 : constant Integer :=
     (10 * (9 * (8 * (7 * (6 * (5 * (4 * (3 * (2 * 1)))))))));
begin
   Silver_IO.Put_Line ("10! =" & Integer'Image (Factorial_10));
end Main;
