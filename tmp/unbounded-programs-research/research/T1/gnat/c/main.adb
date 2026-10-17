procedure Main is
   pragma SPARK_Mode (On);
   A : constant Integer := 0E+800000;
   B : Integer := 1;
begin
   B := A;
end Main;
