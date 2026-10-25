with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- The task gives 3*x+y=-1 and 2*x-3*y=-19.
   -- Substitute y=R1-A1*x into A2*x+B2*y=R2.
   A1 : constant Integer := 3;
   R1 : constant Integer := -1;
   A2 : constant Integer := 2;
   B2 : constant Integer := -3;
   R2 : constant Integer := -19;
   Denominator : constant Integer := (A2 - (B2 * A1));
   Numerator : constant Integer := (R2 - (B2 * R1));
   X : constant Integer := (Numerator / Denominator);
   Y : constant Integer := (R1 - (A1 * X));
begin
   Silver_IO.Put_Line ("x =" & Integer'Image (X));
   Silver_IO.Put_Line ("y =" & Integer'Image (Y));
end Main;
