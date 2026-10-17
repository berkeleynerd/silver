procedure Main is
   pragma SPARK_Mode (On);
   A : constant Integer := 0E99999999999999999999;
   B : Integer := 1;
begin
   B := A;
end Main;
