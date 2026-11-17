with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);

   subtype Small is Integer range -100 .. 100;
   subtype Difference is Integer range -200 .. 200;

   function Subtract
     (Left : in Small;
      Right : in Small) return Difference
   is
   begin
      return (Left - Right);
   end Subtract;

   Result : Difference := 0;
begin
   Result := Subtract (5, 3);
   Silver_IO.Put_Line ("Positional:" & Integer'Image (Result));

   Result := Subtract (Right => 3, Left => 5);
   Silver_IO.Put_Line ("Named, reordered:" & Integer'Image (Result));

   Result := Subtract (5, Right => 3);
   Silver_IO.Put_Line ("Mixed:" & Integer'Image (Result));

   Result := Subtract (Right => 5, Left => 3);
   Silver_IO.Put_Line ("Reversed values:" & Integer'Image (Result));
end Main;
