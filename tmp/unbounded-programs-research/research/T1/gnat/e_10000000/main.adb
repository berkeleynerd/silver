procedure Main is
   pragma SPARK_Mode (On);
   A : constant Integer := 0E10000000;
   B : Integer := 1;
begin
   B := A;
end Main;
