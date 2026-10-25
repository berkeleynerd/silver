with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- A static expression: Ada folds it at compile time and Silver admission
   -- computes the same exact value. Static Integer expressions use literals
   -- and earlier static constants, with grouped +, - and *; user functions
   -- and arbitrary-precision types are outside the current language. Every
   -- intermediate must fit Integer: 12! fits, but 13! is rejected. Silver
   -- also limits each expression to 64 leaves, the program to 63 operators
   -- and the complete source (including comments) to 4096 bytes.
   Factorial_10 : constant Integer :=
     (10 * (9 * (8 * (7 * (6 * (5 * (4 * (3 * (2 * 1)))))))));
begin
   Silver_IO.Put_Line ("10! =" & Integer'Image (Factorial_10));
end Main;
