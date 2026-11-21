with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);

   subtype Component is Integer range -10 .. 10;
   subtype Product is Integer range -300 .. 300;
   type Vector is array (1 .. 3) of Component;

   --  Three terms cover this constrained vector type. Each product lies in
   --  -100 .. 100, so both additions fit the result's declared range.
   function Dot (Left : in Vector; Right : in Vector) return Product is
   begin
      return (Left (Left'First) * Right (Right'First)
              + Left (Left'First + 1) * Right (Right'First + 1)
              + Left (Left'Last) * Right (Right'Last));
   end Dot;

   A : constant Vector := (1, 3, -5);
   B : constant Vector := (4, -2, -1);
   Result : Product := 0;
begin
   Result := Dot (Left => A, Right => B);
   Silver_IO.Put_Line ("Dot product:" & Integer'Image (Result));
end Main;
