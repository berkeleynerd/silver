procedure Main is
   pragma SPARK_Mode (On);
   A : constant Integer := 0E4096;
   B : Integer := 1;
begin
   B := A;
end Main;
