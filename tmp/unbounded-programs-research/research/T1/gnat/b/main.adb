procedure Main is
   pragma SPARK_Mode (On);
   A : constant Integer := 16#0#E799999;
   B : Integer := 1;
begin
   B := A;
end Main;
